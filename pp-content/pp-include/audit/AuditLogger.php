<?php

declare(strict_types=1);

require_once __DIR__ . '/../repositories/BaseRepository.php';

if (!class_exists('AuditLogger')) {
    class AuditLogger extends BaseRepository
    {
        public function log(
            string $actorType,
            string $actorId,
            string $action,
            string $entityName,
            string $entityId,
            ?array $beforeState = null,
            ?array $afterState = null,
            ?string $userAgent = null,
            ?string $ipAddress = null
        ): void {
            $table = $this->table('audit_logs');

            $packedIp = null;
            if (!empty($ipAddress) && filter_var($ipAddress, FILTER_VALIDATE_IP)) {
                $packedIp = @inet_pton($ipAddress) ?: null;
            }

            $sql = "INSERT INTO {$table} (
                        actor_type, actor_id, action, entity_name, entity_id,
                        before_state, after_state, ip_address, user_agent, created_at
                    ) VALUES (
                        :actor_type, :actor_id, :action, :entity_name, :entity_id,
                        :before_state, :after_state, :ip_address, :user_agent, :created_at
                    )";

            $this->execute($sql, [
                ':actor_type' => $actorType,
                ':actor_id' => $actorId,
                ':action' => $action,
                ':entity_name' => $entityName,
                ':entity_id' => $entityId,
                ':before_state' => $beforeState ? json_encode($beforeState, JSON_UNESCAPED_UNICODE) : null,
                ':after_state' => $afterState ? json_encode($afterState, JSON_UNESCAPED_UNICODE) : null,
                ':ip_address' => $packedIp,
                ':user_agent' => $userAgent,
                ':created_at' => $this->nowUtcMicro(),
            ]);
        }
    }
}