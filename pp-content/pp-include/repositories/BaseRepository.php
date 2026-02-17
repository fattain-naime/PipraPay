<?php

declare(strict_types=1);

if (!class_exists('BaseRepository')) {
    class BaseRepository
    {
        protected PDO $pdo;
        protected string $dbPrefix;

        public function __construct(?PDO $pdo = null, ?string $dbPrefix = null)
        {
            global $db_prefix;

            $this->pdo = $pdo ?? connectDatabase();
            $this->dbPrefix = $dbPrefix ?? (string)($db_prefix ?? '');
        }

        protected function table(string $table): string
        {
            return '`' . $this->dbPrefix . $table . '`';
        }

        protected function nowUtcMicro(): string
        {
            $now = new DateTimeImmutable('now', new DateTimeZone('UTC'));
            return $now->format('Y-m-d H:i:s.u');
        }

        protected function fetchOne(string $sql, array $params = []): ?array
        {
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            return $row === false ? null : $row;
        }

        protected function fetchAll(string $sql, array $params = []): array
        {
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute($params);
            return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
        }

        protected function execute(string $sql, array $params = []): bool
        {
            $stmt = $this->pdo->prepare($sql);
            return $stmt->execute($params);
        }
    }
}