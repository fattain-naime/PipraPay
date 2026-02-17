<?php

declare(strict_types=1);

require_once __DIR__ . '/BaseRepository.php';

if (!class_exists('LedgerRepository')) {
    class LedgerRepository extends BaseRepository
    {
        public function upsertJournal(string $eventType, string $externalRef, ?string $legacyTransactionRef = null): int
        {
            $table = $this->table('ledger_journal');

            $sql = "INSERT INTO {$table} (event_type, external_ref, legacy_transaction_ref, created_at)
                    VALUES (:event_type, :external_ref, :legacy_transaction_ref, :created_at)";

            try {
                $this->execute($sql, [
                    ':event_type' => $eventType,
                    ':external_ref' => $externalRef,
                    ':legacy_transaction_ref' => $legacyTransactionRef,
                    ':created_at' => $this->nowUtcMicro(),
                ]);

                return (int)$this->pdo->lastInsertId();
            } catch (PDOException $e) {
                if ((string)$e->getCode() !== '23000') {
                    throw $e;
                }

                $row = $this->fetchOne(
                    "SELECT id FROM {$table} WHERE event_type = :event_type AND external_ref = :external_ref LIMIT 1",
                    [
                        ':event_type' => $eventType,
                        ':external_ref' => $externalRef,
                    ]
                );

                return (int)($row['id'] ?? 0);
            }
        }

        public function hasEntries(int $journalId): bool
        {
            $table = $this->table('ledger_entries');
            $row = $this->fetchOne(
                "SELECT id FROM {$table} WHERE journal_id = :journal_id LIMIT 1",
                [':journal_id' => $journalId]
            );

            return $row !== null;
        }

        public function insertEntry(array $entry): void
        {
            $table = $this->table('ledger_entries');

            $sql = "INSERT INTO {$table} (
                        journal_id, legacy_transaction_ref, account_code,
                        entry_type, amount, currency, created_at
                    ) VALUES (
                        :journal_id, :legacy_transaction_ref, :account_code,
                        :entry_type, :amount, :currency, :created_at
                    )";

            $this->execute($sql, [
                ':journal_id' => $entry['journal_id'],
                ':legacy_transaction_ref' => $entry['legacy_transaction_ref'] ?? null,
                ':account_code' => $entry['account_code'],
                ':entry_type' => $entry['entry_type'],
                ':amount' => $entry['amount'],
                ':currency' => strtoupper(substr((string)$entry['currency'], 0, 3)),
                ':created_at' => $entry['created_at'] ?? $this->nowUtcMicro(),
            ]);
        }
    }
}