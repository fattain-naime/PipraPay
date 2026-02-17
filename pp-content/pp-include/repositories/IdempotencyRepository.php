<?php

declare(strict_types=1);

require_once __DIR__ . '/BaseRepository.php';

if (!class_exists('IdempotencyRepository')) {
    class IdempotencyRepository extends BaseRepository
    {
        public function acquire(string $scope, string $idempotencyKey, string $requestHash): array
        {
            $table = $this->table('idempotency_keys');

            $insertSql = "INSERT INTO {$table} (scope, idempotency_key, request_hash, created_at) VALUES (:scope, :idempotency_key, :request_hash, :created_at)";

            try {
                $this->execute($insertSql, [
                    ':scope' => $scope,
                    ':idempotency_key' => $idempotencyKey,
                    ':request_hash' => $requestHash,
                    ':created_at' => $this->nowUtcMicro(),
                ]);

                return [
                    'state' => 'acquired',
                    'row' => null,
                ];
            } catch (PDOException $e) {
                // 23000: duplicate key -> replay or conflict path.
                if ((string)$e->getCode() !== '23000') {
                    throw $e;
                }

                $existing = $this->fetchOne(
                    "SELECT * FROM {$table} WHERE scope = :scope AND idempotency_key = :idempotency_key LIMIT 1",
                    [
                        ':scope' => $scope,
                        ':idempotency_key' => $idempotencyKey,
                    ]
                );

                if (!$existing) {
                    throw $e;
                }

                if (!hash_equals((string)$existing['request_hash'], $requestHash)) {
                    return [
                        'state' => 'conflict',
                        'row' => $existing,
                    ];
                }

                return [
                    'state' => 'replay',
                    'row' => $existing,
                ];
            }
        }

        public function storeResponse(string $scope, string $idempotencyKey, int $responseCode, array $responseBody): void
        {
            $table = $this->table('idempotency_keys');

            $this->execute(
                "UPDATE {$table} SET response_code = :response_code, response_body = :response_body WHERE scope = :scope AND idempotency_key = :idempotency_key",
                [
                    ':response_code' => $responseCode,
                    ':response_body' => json_encode($responseBody, JSON_UNESCAPED_UNICODE),
                    ':scope' => $scope,
                    ':idempotency_key' => $idempotencyKey,
                ]
            );
        }
    }
}