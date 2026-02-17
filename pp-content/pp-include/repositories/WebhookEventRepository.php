<?php

declare(strict_types=1);

require_once __DIR__ . '/BaseRepository.php';

if (!class_exists('WebhookEventRepository')) {
    class WebhookEventRepository extends BaseRepository
    {
        public function ingest(array $payload): array
        {
            $table = $this->table('webhook_events');

            $sql = "INSERT INTO {$table} (
                        provider, event_id, signature_hash,
                        transaction_ref, payload, status, created_at
                    ) VALUES (
                        :provider, :event_id, :signature_hash,
                        :transaction_ref, :payload, :status, :created_at
                    )";

            try {
                $this->execute($sql, [
                    ':provider' => $payload['provider'],
                    ':event_id' => $payload['event_id'],
                    ':signature_hash' => $payload['signature_hash'],
                    ':transaction_ref' => $payload['transaction_ref'] ?? null,
                    ':payload' => $payload['payload'],
                    ':status' => $payload['status'] ?? 'received',
                    ':created_at' => $payload['created_at'] ?? $this->nowUtcMicro(),
                ]);

                return [
                    'duplicate' => false,
                    'id' => (int)$this->pdo->lastInsertId(),
                ];
            } catch (PDOException $e) {
                if ((string)$e->getCode() !== '23000') {
                    throw $e;
                }

                $existing = $this->fetchOne(
                    "SELECT id, status
                     FROM {$table}
                     WHERE (provider = :provider AND event_id = :event_id)
                        OR signature_hash = :signature_hash
                     ORDER BY id DESC
                     LIMIT 1",
                    [
                        ':provider' => $payload['provider'],
                        ':event_id' => $payload['event_id'],
                        ':signature_hash' => $payload['signature_hash'],
                    ]
                );

                return [
                    'duplicate' => true,
                    'id' => (int)($existing['id'] ?? 0),
                ];
            }
        }

        public function markProcessed(int $id, string $status = 'processed'): void
        {
            $table = $this->table('webhook_events');

            $this->execute(
                "UPDATE {$table} SET status = :status, processed_at = :processed_at WHERE id = :id",
                [
                    ':status' => $status,
                    ':processed_at' => $this->nowUtcMicro(),
                    ':id' => $id,
                ]
            );
        }
    }
}
