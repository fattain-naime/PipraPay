<?php

declare(strict_types=1);

require_once __DIR__ . '/../repositories/PaymentRepository.php';
require_once __DIR__ . '/IdempotencyService.php';
require_once __DIR__ . '/../audit/AuditLogger.php';

if (!class_exists('PaymentService')) {
    class PaymentService
    {
        private PDO $pdo;
        private PaymentRepository $paymentRepository;
        private IdempotencyService $idempotencyService;
        private AuditLogger $auditLogger;

        public function __construct(?PDO $pdo = null)
        {
            $this->pdo = $pdo ?? connectDatabase();
            $this->paymentRepository = new PaymentRepository($this->pdo);
            $this->idempotencyService = new IdempotencyService(new IdempotencyRepository($this->pdo));
            $this->auditLogger = new AuditLogger($this->pdo);
        }

        public function initiate(array $payload): array
        {
            $brandId = (string)$payload['brand_id'];
            $source = (string)($payload['source'] ?? 'api');
            $amount = money_sanitize($payload['amount'] ?? '0');
            $currency = strtoupper(substr((string)($payload['currency'] ?? 'BDT'), 0, 10));
            $customer = $payload['customer'] ?? [];

            $customerInfo = json_encode([
                'name' => (string)($customer['name'] ?? ''),
                'email' => (string)($customer['email'] ?? ''),
                'mobile' => (string)($customer['mobile'] ?? ''),
            ], JSON_UNESCAPED_UNICODE);

            $metadataJson = null;
            if (array_key_exists('metadata', $payload)) {
                $metadataJson = json_encode($payload['metadata'], JSON_UNESCAPED_UNICODE);
            }

            $sourceInfoJson = null;
            if (array_key_exists('source_info', $payload)) {
                $sourceInfoJson = json_encode($payload['source_info'], JSON_UNESCAPED_UNICODE);
            }

            $idempotencyKey = trim((string)($payload['idempotency_key'] ?? ''));
            $idempotencyScope = (string)($payload['idempotency_scope'] ?? ('payment:init:' . $brandId));

            $requestHash = hash('sha256', json_encode([
                'brand_id' => $brandId,
                'source' => $source,
                'amount' => $amount,
                'currency' => $currency,
                'customer' => $customer,
                'metadata' => $payload['metadata'] ?? null,
                'return_url' => $payload['return_url'] ?? '--',
                'webhook_url' => $payload['webhook_url'] ?? '--',
            ], JSON_UNESCAPED_UNICODE));

            $now = new DateTimeImmutable('now', new DateTimeZone('UTC'));
            $nowDate = $now->format('Y-m-d H:i:s');
            $nowMicro = $now->format('Y-m-d H:i:s.u');

            $this->pdo->beginTransaction();

            try {
                if ($idempotencyKey !== '') {
                    $acquireResult = $this->idempotencyService->acquire($idempotencyScope, $idempotencyKey, $requestHash);

                    if ($acquireResult['state'] === 'conflict') {
                        throw new RuntimeException('Idempotency key conflict: payload mismatch.');
                    }

                    if ($acquireResult['state'] === 'replay') {
                        $cachedBody = $acquireResult['row']['response_body'] ?? null;
                        if (is_string($cachedBody) && $cachedBody !== '') {
                            $decoded = json_decode($cachedBody, true);
                            if (is_array($decoded) && !empty($decoded['payment_id'])) {
                                $this->pdo->commit();
                                $decoded['replay'] = true;
                                return $decoded;
                            }
                        }

                        throw new RuntimeException('Duplicate request is currently being processed.');
                    }
                }

                $paymentId = $this->generatePaymentId();

                $this->paymentRepository->createLegacyTransaction([
                    'brand_id' => $brandId,
                    'source' => $source,
                    'ref' => $paymentId,
                    'customer_info' => $customerInfo,
                    'amount' => $amount,
                    'currency' => $currency,
                    'source_info' => $sourceInfoJson,
                    'metadata' => $metadataJson,
                    'return_url' => $payload['return_url'] ?? '--',
                    'webhook_url' => $payload['webhook_url'] ?? '--',
                    'created_date' => $nowDate,
                    'updated_date' => $nowDate,
                    'created_at' => $nowMicro,
                    'updated_at' => $nowMicro,
                ]);

                $intentId = $this->paymentRepository->createPaymentIntent([
                    'legacy_transaction_ref' => $paymentId,
                    'brand_id' => $brandId,
                    'source' => $source,
                    'amount' => $amount,
                    'currency' => $currency,
                    'customer_name' => $customer['name'] ?? null,
                    'customer_email' => $customer['email'] ?? null,
                    'customer_mobile' => $customer['mobile'] ?? null,
                    'idempotency_key' => $idempotencyKey !== '' ? $idempotencyKey : null,
                    'metadata' => $metadataJson,
                    'status' => 'initiated',
                    'created_at' => $nowMicro,
                    'updated_at' => $nowMicro,
                ]);

                $this->paymentRepository->createPaymentAttempt([
                    'intent_id' => $intentId,
                    'status' => 'initiated',
                    'created_at' => $nowMicro,
                    'updated_at' => $nowMicro,
                ]);

                $this->auditLogger->log(
                    'system',
                    $brandId,
                    'payment_initiated',
                    'transaction',
                    $paymentId,
                    null,
                    [
                        'source' => $source,
                        'amount' => $amount,
                        'currency' => $currency,
                        'intent_id' => $intentId,
                    ],
                    $_SERVER['HTTP_USER_AGENT'] ?? null,
                    $_SERVER['REMOTE_ADDR'] ?? null
                );

                $result = [
                    'payment_id' => $paymentId,
                    'intent_id' => $intentId,
                    'replay' => false,
                ];

                if ($idempotencyKey !== '') {
                    $this->idempotencyService->storeResponse($idempotencyScope, $idempotencyKey, 200, $result);
                }

                $this->pdo->commit();

                return $result;
            } catch (Throwable $e) {
                if ($this->pdo->inTransaction()) {
                    $this->pdo->rollBack();
                }
                throw $e;
            }
        }

        private function generatePaymentId(): string
        {
            $id = '';
            for ($i = 0; $i < 27; $i++) {
                $id .= (string)random_int(0, 9);
            }
            return $id;
        }
    }
}