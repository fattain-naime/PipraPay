<?php

declare(strict_types=1);

require_once __DIR__ . '/../repositories/WebhookEventRepository.php';

if (!class_exists('WebhookService')) {
    class WebhookService
    {
        private WebhookEventRepository $repository;

        public function __construct(?WebhookEventRepository $repository = null)
        {
            $this->repository = $repository ?? new WebhookEventRepository();
        }

        public function verifySignature(string $payload, string $providedSignature, string $secret): bool
        {
            $providedSignature = trim($providedSignature);
            if ($providedSignature === '' || $secret === '') {
                return false;
            }

            $calculated = hash_hmac('sha256', $payload, $secret);
            return hash_equals($calculated, $providedSignature);
        }

        public function extractEventEpoch(array $payload, array $server = []): ?int
        {
            $headerCandidates = [
                $server['HTTP_X_PIPRAPAY_TIMESTAMP'] ?? null,
                $server['HTTP_X_TIMESTAMP'] ?? null,
                $server['HTTP_X_EVENT_TIMESTAMP'] ?? null,
            ];

            foreach ($headerCandidates as $candidate) {
                $normalized = $this->normalizeEpoch($candidate);
                if ($normalized !== null) {
                    return $normalized;
                }
            }

            $payloadCandidates = [
                $payload['timestamp'] ?? null,
                $payload['event_timestamp'] ?? null,
                $payload['event_time'] ?? null,
                $payload['created_at'] ?? null,
                $payload['sent_at'] ?? null,
                $payload['occurred_at'] ?? null,
            ];

            foreach ($payloadCandidates as $candidate) {
                $normalized = $this->normalizeEpoch($candidate);
                if ($normalized !== null) {
                    return $normalized;
                }
            }

            return null;
        }

        public function validateTimestamp(?int $eventEpoch, int $maxAgeSeconds, int $clockSkewSeconds, bool $required = true): array
        {
            if ($eventEpoch === null) {
                return [
                    'valid' => !$required,
                    'reason' => 'missing_timestamp',
                    'age_seconds' => null,
                ];
            }

            $now = time();
            $age = $now - $eventEpoch;

            if ($age < (0 - $clockSkewSeconds)) {
                return [
                    'valid' => false,
                    'reason' => 'future_timestamp',
                    'age_seconds' => $age,
                ];
            }

            if ($age > ($maxAgeSeconds + $clockSkewSeconds)) {
                return [
                    'valid' => false,
                    'reason' => 'expired_timestamp',
                    'age_seconds' => $age,
                ];
            }

            return [
                'valid' => true,
                'reason' => 'ok',
                'age_seconds' => $age,
            ];
        }

        public function ingest(string $provider, string $eventId, string $rawPayload, string $signature = '', ?string $transactionRef = null): array
        {
            $signatureHash = hash('sha256', $signature === '' ? $rawPayload : $signature);

            return $this->repository->ingest([
                'provider' => $provider,
                'event_id' => $eventId,
                'signature_hash' => $signatureHash,
                'transaction_ref' => $transactionRef,
                'payload' => $rawPayload,
                'status' => 'received',
            ]);
        }

        public function complete(int $eventId, string $status = 'processed'): void
        {
            $this->repository->markProcessed($eventId, $status);
        }

        private function normalizeEpoch($value): ?int
        {
            if ($value === null) {
                return null;
            }

            if (is_int($value) || is_float($value) || (is_string($value) && preg_match('/^\d+$/', trim($value)))) {
                $numeric = (float)$value;

                if ($numeric > 9999999999) {
                    $numeric = $numeric / 1000;
                }

                $epoch = (int)floor($numeric);
                if ($epoch > 0) {
                    return $epoch;
                }
            }

            if (is_string($value)) {
                $timestamp = strtotime(trim($value));
                if ($timestamp !== false && $timestamp > 0) {
                    return (int)$timestamp;
                }
            }

            return null;
        }
    }
}
