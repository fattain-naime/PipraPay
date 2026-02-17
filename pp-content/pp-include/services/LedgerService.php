<?php

declare(strict_types=1);

require_once __DIR__ . '/../repositories/LedgerRepository.php';

if (!class_exists('LedgerService')) {
    class LedgerService
    {
        private LedgerRepository $repository;

        public function __construct(?LedgerRepository $repository = null)
        {
            $this->repository = $repository ?? new LedgerRepository();
        }

        public function postJournal(string $eventType, string $externalRef, ?string $legacyTransactionRef, array $lines): void
        {
            $debit = '0';
            $credit = '0';

            foreach ($lines as $line) {
                $amount = money_sanitize($line['amount'] ?? '0');
                if (($line['entry_type'] ?? '') === 'debit') {
                    $debit = money_add($debit, $amount);
                }

                if (($line['entry_type'] ?? '') === 'credit') {
                    $credit = money_add($credit, $amount);
                }
            }

            if (bccomp($debit, $credit, 8) !== 0) {
                throw new RuntimeException('Ledger invariant violation: debit and credit mismatch.');
            }

            $journalId = $this->repository->upsertJournal($eventType, $externalRef, $legacyTransactionRef);
            if ($journalId <= 0 || $this->repository->hasEntries($journalId)) {
                return;
            }

            foreach ($lines as $line) {
                $this->repository->insertEntry([
                    'journal_id' => $journalId,
                    'legacy_transaction_ref' => $legacyTransactionRef,
                    'account_code' => $line['account_code'],
                    'entry_type' => $line['entry_type'],
                    'amount' => money_sanitize($line['amount']),
                    'currency' => strtoupper(substr((string)$line['currency'], 0, 3)),
                ]);
            }
        }

        public function postForTransaction(array $transaction, string $status): void
        {
            $ref = (string)($transaction['ref'] ?? '');
            if ($ref === '') {
                return;
            }

            $amount = money_sanitize($transaction['amount'] ?? '0');
            if (bccomp($amount, '0', 8) <= 0) {
                return;
            }

            $currency = strtoupper(substr((string)($transaction['currency'] ?? 'BDT'), 0, 3));

            if ($status === 'completed') {
                $this->postJournal('transaction_completed', $ref, $ref, [
                    [
                        'account_code' => 'gateway_clearing',
                        'entry_type' => 'debit',
                        'amount' => $amount,
                        'currency' => $currency,
                    ],
                    [
                        'account_code' => 'merchant_receivable',
                        'entry_type' => 'credit',
                        'amount' => $amount,
                        'currency' => $currency,
                    ],
                ]);
            }

            if ($status === 'refunded') {
                $this->postJournal('transaction_refunded', $ref, $ref, [
                    [
                        'account_code' => 'merchant_receivable',
                        'entry_type' => 'debit',
                        'amount' => $amount,
                        'currency' => $currency,
                    ],
                    [
                        'account_code' => 'gateway_clearing',
                        'entry_type' => 'credit',
                        'amount' => $amount,
                        'currency' => $currency,
                    ],
                ]);
            }
        }
    }
}