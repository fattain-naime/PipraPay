<?php

declare(strict_types=1);

require_once __DIR__ . '/BaseRepository.php';

if (!class_exists('ApiKeyRepository')) {
    class ApiKeyRepository extends BaseRepository
    {
        public function findActiveCredential(string $presentedKey): ?array
        {
            $hash = hash('sha256', $presentedKey);

            $apiKeysTable = $this->table('api_keys');
            $apiTable = $this->table('api');

            $hashedRow = $this->fetchOne(
                "SELECT k.*, a.api_scopes, a.expired_date, a.created_date, a.updated_date
                 FROM {$apiKeysTable} k
                 INNER JOIN {$apiTable} a ON a.id = k.api_id
                 WHERE k.key_hash = :key_hash
                   AND k.status = 'active'
                   AND a.status = 'active'
                   AND (k.expired_at IS NULL OR k.expired_at >= UTC_TIMESTAMP(6))
                 LIMIT 1",
                [':key_hash' => $hash]
            );

            if ($hashedRow) {
                return [
                    'auth_model' => 'hashed',
                    'id' => $hashedRow['api_id'],
                    'brand_id' => $hashedRow['brand_id'],
                    'name' => $hashedRow['name'],
                    'status' => $hashedRow['status'],
                    'api_scopes' => $hashedRow['scopes'] ?: $hashedRow['api_scopes'],
                    'expired_date' => $hashedRow['expired_date'] ?? '--',
                ];
            }
            
            return null;
        }

        public function createHashedKey(int $apiId, string $brandId, string $name, string $rawKey, array $scopes, ?string $expiredAt, string $status = 'active'): void
        {
            $table = $this->table('api_keys');

            $sql = "INSERT INTO {$table} (
                        api_id, brand_id, name, key_hash, key_prefix,
                        scopes, status, expired_at, created_at, updated_at
                    ) VALUES (
                        :api_id, :brand_id, :name, :key_hash, :key_prefix,
                        :scopes, :status, :expired_at, :created_at, :updated_at
                    )";

            $this->execute($sql, [
                ':api_id' => $apiId,
                ':brand_id' => $brandId,
                ':name' => $name,
                ':key_hash' => hash('sha256', $rawKey),
                ':key_prefix' => substr($rawKey, 0, 8),
                ':scopes' => json_encode(array_values($scopes), JSON_UNESCAPED_UNICODE),
                ':status' => $status === 'inactive' ? 'inactive' : 'active',
                ':expired_at' => $expiredAt,
                ':created_at' => $this->nowUtcMicro(),
                ':updated_at' => $this->nowUtcMicro(),
            ]);
        }

        public function updateByApiId(int $apiId, string $name, array $scopes, ?string $expiredAt, string $status): void
        {
            $table = $this->table('api_keys');

            $sql = "UPDATE {$table}
                    SET name = :name,
                        scopes = :scopes,
                        expired_at = :expired_at,
                        status = :status,
                        updated_at = :updated_at
                    WHERE api_id = :api_id";

            $this->execute($sql, [
                ':name' => $name,
                ':scopes' => json_encode(array_values($scopes), JSON_UNESCAPED_UNICODE),
                ':expired_at' => $expiredAt,
                ':status' => $status === 'inactive' ? 'inactive' : 'active',
                ':updated_at' => $this->nowUtcMicro(),
                ':api_id' => $apiId,
            ]);
        }

        public function getMaskedKeyByApiId(int $apiId): ?string
        {
            $table = $this->table('api_keys');
            $row = $this->fetchOne(
                "SELECT key_prefix FROM {$table} WHERE api_id = :api_id ORDER BY id DESC LIMIT 1",
                [':api_id' => $apiId]
            );

            if (!$row || empty($row['key_prefix'])) {
                return null;
            }

            return $row['key_prefix'] . str_repeat('*', 24);
        }
    }
}
