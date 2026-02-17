<?php

declare(strict_types=1);

require_once __DIR__ . '/BaseRepository.php';

if (!class_exists('PaymentRepository')) {
    class PaymentRepository extends BaseRepository
    {
        public function createLegacyTransaction(array $payload): void
        {
            $table = $this->table('transaction');

            $sql = "INSERT INTO {$table} (
                        brand_id, source, ref, customer_info, amount, processing_fee,
                        discount_amount, local_net_amount, currency, local_currency,
                        sender, trx_id, trx_slip, gateway_id, sender_key, sender_type,
                        source_info, metadata, status, return_url, webhook_url,
                        created_date, updated_date, created_at, updated_at
                    ) VALUES (
                        :brand_id, :source, :ref, :customer_info, :amount, :processing_fee,
                        :discount_amount, :local_net_amount, :currency, :local_currency,
                        :sender, :trx_id, :trx_slip, :gateway_id, :sender_key, :sender_type,
                        :source_info, :metadata, :status, :return_url, :webhook_url,
                        :created_date, :updated_date, :created_at, :updated_at
                    )";

            $this->execute($sql, [
                ':brand_id' => $payload['brand_id'],
                ':source' => $payload['source'],
                ':ref' => $payload['ref'],
                ':customer_info' => $payload['customer_info'],
                ':amount' => $payload['amount'],
                ':processing_fee' => $payload['processing_fee'] ?? '0',
                ':discount_amount' => $payload['discount_amount'] ?? '0',
                ':local_net_amount' => $payload['local_net_amount'] ?? '0',
                ':currency' => $payload['currency'],
                ':local_currency' => $payload['local_currency'] ?? null,
                ':sender' => $payload['sender'] ?? '--',
                ':trx_id' => $payload['trx_id'] ?? null,
                ':trx_slip' => $payload['trx_slip'] ?? null,
                ':gateway_id' => $payload['gateway_id'] ?? '--',
                ':sender_key' => $payload['sender_key'] ?? '--',
                ':sender_type' => $payload['sender_type'] ?? '--',
                ':source_info' => $payload['source_info'] ?? null,
                ':metadata' => $payload['metadata'] ?? null,
                ':status' => $payload['status'] ?? 'initiated',
                ':return_url' => $payload['return_url'] ?? '--',
                ':webhook_url' => $payload['webhook_url'] ?? '--',
                ':created_date' => $payload['created_date'],
                ':updated_date' => $payload['updated_date'],
                ':created_at' => $payload['created_at'] ?? $this->nowUtcMicro(),
                ':updated_at' => $payload['updated_at'] ?? $this->nowUtcMicro(),
            ]);
        }

        public function createPaymentIntent(array $payload): int
        {
            $table = $this->table('payment_intents');

            $sql = "INSERT INTO {$table} (
                        legacy_transaction_ref, brand_id, source, amount, currency,
                        customer_name, customer_email, customer_mobile,
                        idempotency_key, metadata, status, created_at, updated_at
                    ) VALUES (
                        :legacy_transaction_ref, :brand_id, :source, :amount, :currency,
                        :customer_name, :customer_email, :customer_mobile,
                        :idempotency_key, :metadata, :status, :created_at, :updated_at
                    )";

            $this->execute($sql, [
                ':legacy_transaction_ref' => $payload['legacy_transaction_ref'],
                ':brand_id' => $payload['brand_id'],
                ':source' => $payload['source'],
                ':amount' => $payload['amount'],
                ':currency' => strtoupper(substr((string)$payload['currency'], 0, 3)),
                ':customer_name' => $payload['customer_name'] ?? null,
                ':customer_email' => $payload['customer_email'] ?? null,
                ':customer_mobile' => $payload['customer_mobile'] ?? null,
                ':idempotency_key' => $payload['idempotency_key'] ?? null,
                ':metadata' => $payload['metadata'] ?? null,
                ':status' => $payload['status'] ?? 'initiated',
                ':created_at' => $payload['created_at'] ?? $this->nowUtcMicro(),
                ':updated_at' => $payload['updated_at'] ?? $this->nowUtcMicro(),
            ]);

            return (int)$this->pdo->lastInsertId();
        }

        public function createPaymentAttempt(array $payload): int
        {
            $table = $this->table('payment_attempts');

            $sql = "INSERT INTO {$table} (
                        intent_id, gateway_id, attempt_no, status,
                        provider_ref, request_payload, response_payload,
                        created_at, updated_at
                    ) VALUES (
                        :intent_id, :gateway_id, :attempt_no, :status,
                        :provider_ref, :request_payload, :response_payload,
                        :created_at, :updated_at
                    )";

            $this->execute($sql, [
                ':intent_id' => $payload['intent_id'],
                ':gateway_id' => $payload['gateway_id'] ?? null,
                ':attempt_no' => $payload['attempt_no'] ?? 1,
                ':status' => $payload['status'] ?? 'initiated',
                ':provider_ref' => $payload['provider_ref'] ?? null,
                ':request_payload' => $payload['request_payload'] ?? null,
                ':response_payload' => $payload['response_payload'] ?? null,
                ':created_at' => $payload['created_at'] ?? $this->nowUtcMicro(),
                ':updated_at' => $payload['updated_at'] ?? $this->nowUtcMicro(),
            ]);

            return (int)$this->pdo->lastInsertId();
        }

        public function getTransactionByRef(string $ref): ?array
        {
            $table = $this->table('transaction');

            return $this->fetchOne(
                "SELECT * FROM {$table} WHERE ref = :ref LIMIT 1",
                [':ref' => $ref]
            );
        }
    }
}