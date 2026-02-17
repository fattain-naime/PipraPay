#!/usr/bin/env php
<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This script must be run from CLI.\n");
    exit(1);
}

error_reporting(E_ALL);
ini_set('display_errors', '1');

final class SmokeRunner
{
    private PDO $pdo;
    private string $prefix;
    private string $runId;
    private bool $cleanupEnabled;
    private bool $verbose;
    private ?string $reportPath;
    private ?string $brandId = null;
    private ?string $paymentRef = null;
    private ?string $idempotencyScope = null;
    private ?string $idempotencyKey = null;
    private ?string $webhookEventId = null;
    private ?string $rollbackMarker = null;
    /** @var array<int, array<string, mixed>> */
    private array $results = [];
    private bool $hasFailure = false;

    public function __construct(bool $cleanupEnabled, bool $verbose, ?string $reportPath)
    {
        $this->cleanupEnabled = $cleanupEnabled;
        $this->verbose = $verbose;
        $this->reportPath = $reportPath;
        $this->runId = gmdate('YmdHis') . '-' . substr(bin2hex(random_bytes(4)), 0, 8);
    }

    public function run(): int
    {
        $startedAt = gmdate('c');
        $this->println("== PipraPay WS-6 Release Smoke Suite ==");
        $this->println("Run ID: {$this->runId}");

        try {
            $this->bootstrap();
            $this->loadContext();

            $this->runTest('IDEMPOTENCY_REPLAY', function (): void {
                $this->testIdempotencyReplay();
            });

            $this->runTest('DUPLICATE_WEBHOOK', function (): void {
                $this->testDuplicateWebhookDedupe();
            });

            $this->runTest('LEDGER_INVARIANT', function (): void {
                $this->testLedgerInvariant();
            });

            $this->runTest('ROLLBACK_PARTIAL_FAILURE', function (): void {
                $this->testRollbackOnPartialFailure();
            });
        } catch (Throwable $e) {
            $this->hasFailure = true;
            $this->results[] = [
                'name' => 'SUITE_SETUP',
                'status' => 'FAIL',
                'message' => $e->getMessage(),
            ];
            $this->println('[FAIL] SUITE_SETUP: ' . $e->getMessage());
        } finally {
            if ($this->cleanupEnabled) {
                $this->cleanupArtifacts();
            }
        }

        $finishedAt = gmdate('c');
        $summary = [
            'suite' => 'piprapay_ws6_release_smoke',
            'run_id' => $this->runId,
            'started_at' => $startedAt,
            'finished_at' => $finishedAt,
            'cleanup_enabled' => $this->cleanupEnabled,
            'status' => $this->hasFailure ? 'FAIL' : 'PASS',
            'results' => $this->results,
        ];

        if ($this->reportPath !== null) {
            $this->writeReport($summary, $this->reportPath);
        }

        $this->println('');
        $this->println('== Summary ==');
        $this->println('Status: ' . $summary['status']);
        $this->println('Tests: ' . count($this->results));

        return $this->hasFailure ? 1 : 0;
    }

    private function bootstrap(): void
    {
        $root = dirname(__DIR__, 2);
        $configCandidates = [
            $root . DIRECTORY_SEPARATOR . 'pp-config.php',
            $root . DIRECTORY_SEPARATOR . 'pp-temp-config.php',
        ];

        $configLoaded = false;
        foreach ($configCandidates as $configPath) {
            if (is_file($configPath)) {
                /** @var array<string, string|null> $configValues */
                $configValues = (static function (string $path): array {
                    include $path;
                    return [
                        'db_host' => isset($db_host) ? (string)$db_host : null,
                        'db_user' => isset($db_user) ? (string)$db_user : null,
                        'db_pass' => isset($db_pass) ? (string)$db_pass : null,
                        'db_name' => isset($db_name) ? (string)$db_name : null,
                        'db_prefix' => isset($db_prefix) ? (string)$db_prefix : null,
                    ];
                })($configPath);

                foreach ($configValues as $key => $value) {
                    if ($value !== null) {
                        $GLOBALS[$key] = $value;
                    }
                }
                $configLoaded = true;
                break;
            }
        }

        if (!$configLoaded) {
            throw new RuntimeException('Config file not found. Expected pp-config.php or pp-temp-config.php at project root.');
        }

        $requiredConfigKeys = ['db_host', 'db_user', 'db_name', 'db_prefix'];
        foreach ($requiredConfigKeys as $requiredKey) {
            if (!isset($GLOBALS[$requiredKey]) || trim((string)$GLOBALS[$requiredKey]) === '') {
                throw new RuntimeException('Config key missing or empty: ' . $requiredKey);
            }
        }

        if (!defined('PipraPay_INIT')) {
            define('PipraPay_INIT', true);
        }

        $functionsPath = $root . DIRECTORY_SEPARATOR . 'pp-content' . DIRECTORY_SEPARATOR . 'pp-include' . DIRECTORY_SEPARATOR . 'pp-functions.php';
        if (!is_file($functionsPath)) {
            throw new RuntimeException('pp-functions.php not found.');
        }
        require_once $functionsPath;

        if (!function_exists('connectDatabase')) {
            throw new RuntimeException('connectDatabase() is not available after bootstrap.');
        }
        if (!function_exists('pp_initiate_payment')) {
            throw new RuntimeException('pp_initiate_payment() is not available after bootstrap.');
        }

        $this->pdo = connectDatabase();

        /** @var string $db_prefix */
        global $db_prefix;
        $this->prefix = (string)$db_prefix;
        if ($this->prefix === '') {
            throw new RuntimeException('Database prefix is empty.');
        }
    }

    private function loadContext(): void
    {
        if (!function_exists('pp_assert_fintech_schema_ready')) {
            throw new RuntimeException('Schema readiness helper is not available.');
        }

        if (!pp_assert_fintech_schema_ready()) {
            throw new RuntimeException('Fintech schema is not ready.');
        }

        $brandRow = $this->fetchOne(
            'SELECT brand_id FROM ' . $this->table('brands') . ' ORDER BY id ASC LIMIT 1',
            []
        );
        if ($brandRow === null || empty($brandRow['brand_id'])) {
            throw new RuntimeException('No brand found. Complete installer admin setup first.');
        }
        $this->brandId = (string)$brandRow['brand_id'];

        $this->println('Brand Context: ' . $this->brandId);
        $this->println('DB Prefix: ' . $this->prefix);
    }

    private function testIdempotencyReplay(): void
    {
        if ($this->brandId === null) {
            throw new RuntimeException('Brand context not loaded.');
        }

        $scopeSeed = substr(str_replace(['-', '_'], '', $this->runId), 0, 18);
        $this->idempotencyScope = 'smk:' . $scopeSeed;
        $this->idempotencyKey = 'idem-' . substr($scopeSeed, 0, 24);

        $payload = [
            'brand_id' => $this->brandId,
            'source' => 'api',
            'amount' => '123.45',
            'currency' => 'BDT',
            'customer' => [
                'name' => 'Smoke User',
                'email' => 'smoke+' . substr($scopeSeed, 0, 6) . '@example.test',
                'mobile' => '01700000000',
            ],
            'metadata' => [
                'smoke_suite' => true,
                'run_id' => $this->runId,
                'case' => 'idempotency_replay',
            ],
            'return_url' => '--',
            'webhook_url' => '--',
            'idempotency_key' => $this->idempotencyKey,
            'idempotency_scope' => $this->idempotencyScope,
        ];

        $first = pp_initiate_payment($payload);
        $second = pp_initiate_payment($payload);

        if (empty($first['payment_id'])) {
            throw new RuntimeException('First payment init did not return payment_id.');
        }
        if (($second['payment_id'] ?? '') !== $first['payment_id']) {
            throw new RuntimeException('Replay payment_id mismatch.');
        }
        if (($second['replay'] ?? false) !== true) {
            throw new RuntimeException('Replay flag is not true for second request.');
        }

        $this->paymentRef = (string)$first['payment_id'];

        $stored = $this->fetchOne(
            'SELECT response_code, response_body FROM ' . $this->table('idempotency_keys') . ' WHERE scope = :scope AND idempotency_key = :idempotency_key LIMIT 1',
            [
                ':scope' => $this->idempotencyScope,
                ':idempotency_key' => $this->idempotencyKey,
            ]
        );
        if ($stored === null) {
            throw new RuntimeException('Idempotency record not found.');
        }
        if ((int)($stored['response_code'] ?? 0) !== 200) {
            throw new RuntimeException('Idempotency response_code is not 200.');
        }

        $body = json_decode((string)($stored['response_body'] ?? ''), true);
        if (!is_array($body) || (string)($body['payment_id'] ?? '') !== $this->paymentRef) {
            throw new RuntimeException('Idempotency response_body does not match payment_id.');
        }

        $conflictPayload = $payload;
        $conflictPayload['amount'] = '200.00';
        $conflictTriggered = false;
        try {
            pp_initiate_payment($conflictPayload);
        } catch (RuntimeException $e) {
            if (stripos($e->getMessage(), 'idempotency key conflict') !== false) {
                $conflictTriggered = true;
            }
        }

        if (!$conflictTriggered) {
            throw new RuntimeException('Idempotency conflict check did not trigger expected exception.');
        }
    }

    private function testDuplicateWebhookDedupe(): void
    {
        if ($this->paymentRef === null) {
            throw new RuntimeException('paymentRef not available from idempotency test.');
        }

        $this->webhookEventId = 'smk-evt-' . substr(str_replace('-', '', $this->runId), 0, 20);
        $payload = [
            'event_id' => $this->webhookEventId,
            'pp_id' => $this->paymentRef,
            'status' => 'completed',
            'timestamp' => time(),
            'run_id' => $this->runId,
        ];
        $raw = json_encode($payload, JSON_UNESCAPED_UNICODE);
        if (!is_string($raw)) {
            throw new RuntimeException('Failed to encode webhook payload.');
        }

        $secret = 'smoke-webhook-secret-' . substr(str_replace('-', '', $this->runId), 0, 12);
        $signature = hash_hmac('sha256', $raw, $secret);

        $service = pp_get_webhook_service();
        if (!$service->verifySignature($raw, $signature, $secret)) {
            throw new RuntimeException('Webhook signature verification failed for valid payload.');
        }

        $first = $service->ingest('invoice', $this->webhookEventId, $raw, $signature, $this->paymentRef);
        $second = $service->ingest('invoice', $this->webhookEventId, $raw, $signature, $this->paymentRef);

        if (!empty($first['duplicate'])) {
            throw new RuntimeException('First webhook ingest unexpectedly marked as duplicate.');
        }
        if (empty($first['id'])) {
            throw new RuntimeException('First webhook ingest did not return event id.');
        }
        if (empty($second['duplicate'])) {
            throw new RuntimeException('Second webhook ingest should be duplicate but is not.');
        }

        $service->complete((int)$first['id'], 'processed');

        $countRow = $this->fetchOne(
            'SELECT COUNT(*) AS total FROM ' . $this->table('webhook_events') . ' WHERE provider = :provider AND event_id = :event_id',
            [
                ':provider' => 'invoice',
                ':event_id' => $this->webhookEventId,
            ]
        );
        $count = (int)($countRow['total'] ?? 0);
        if ($count !== 1) {
            throw new RuntimeException('Webhook dedupe count mismatch. Expected 1 row, got ' . $count . '.');
        }
    }

    private function testLedgerInvariant(): void
    {
        if ($this->paymentRef === null) {
            throw new RuntimeException('paymentRef not available from previous tests.');
        }

        $completed = pp_transition_transaction_status(
            $this->paymentRef,
            'completed',
            [
                'gateway_id' => '--',
                'trx_id' => 'smk-' . substr(str_replace('-', '', $this->runId), 0, 18),
            ],
            [
                'actor_type' => 'smoke-suite',
                'actor_id' => 'ws6',
                'gateway_id' => '--',
                'provider_ref' => 'smoke-complete',
            ]
        );
        if (!$completed) {
            throw new RuntimeException('Failed to transition transaction to completed.');
        }

        $refunded = pp_transition_transaction_status(
            $this->paymentRef,
            'refunded',
            [],
            [
                'actor_type' => 'smoke-suite',
                'actor_id' => 'ws6',
                'gateway_id' => '--',
                'provider_ref' => 'smoke-refund',
            ]
        );
        if (!$refunded) {
            throw new RuntimeException('Failed to transition transaction to refunded.');
        }

        $rows = $this->fetchAll(
            'SELECT j.id, j.event_type,
                    SUM(CASE WHEN e.entry_type = \'debit\' THEN e.amount ELSE 0 END) AS total_debit,
                    SUM(CASE WHEN e.entry_type = \'credit\' THEN e.amount ELSE 0 END) AS total_credit
             FROM ' . $this->table('ledger_journal') . ' j
             INNER JOIN ' . $this->table('ledger_entries') . ' e ON e.journal_id = j.id
             WHERE j.external_ref = :ref
             GROUP BY j.id, j.event_type
             ORDER BY j.id ASC',
            [':ref' => $this->paymentRef]
        );

        if (count($rows) < 2) {
            throw new RuntimeException('Expected at least 2 ledger journals (completed + refunded).');
        }

        foreach ($rows as $row) {
            $debit = money_sanitize((string)($row['total_debit'] ?? '0'));
            $credit = money_sanitize((string)($row['total_credit'] ?? '0'));
            if (bccomp($debit, $credit, 8) !== 0) {
                throw new RuntimeException(
                    'Ledger invariant failed for journal ' . (string)$row['id'] .
                    ' (' . (string)$row['event_type'] . '): debit=' . $debit . ', credit=' . $credit
                );
            }
        }
    }

    private function testRollbackOnPartialFailure(): void
    {
        $this->rollbackMarker = 'rollback-' . substr(str_replace('-', '', $this->runId), 0, 18);
        $invalidBrand = substr('INV' . str_replace('-', '', $this->runId), 0, 15);

        $failed = false;
        try {
            pp_initiate_payment([
                'brand_id' => $invalidBrand,
                'source' => 'api',
                'amount' => '10.00',
                'currency' => 'BDT',
                'customer' => [
                    'name' => 'Rollback Smoke',
                    'email' => 'rollback+' . substr($this->rollbackMarker, -6) . '@example.test',
                    'mobile' => '01700000001',
                ],
                'metadata' => [
                    'smoke_suite' => true,
                    'run_id' => $this->runId,
                    'rollback_marker' => $this->rollbackMarker,
                ],
                'return_url' => '--',
                'webhook_url' => '--',
            ]);
        } catch (Throwable $e) {
            $failed = true;
            if ($this->verbose) {
                $this->println('Rollback expected exception: ' . $e->getMessage());
            }
        }

        if (!$failed) {
            throw new RuntimeException('Rollback scenario did not fail as expected.');
        }

        $row = $this->fetchOne(
            'SELECT COUNT(*) AS total FROM ' . $this->table('transaction') . ' WHERE metadata LIKE :marker',
            [':marker' => '%"rollback_marker":"' . $this->rollbackMarker . '"%']
        );
        $count = (int)($row['total'] ?? 0);
        if ($count !== 0) {
            throw new RuntimeException('Rollback failed: found ' . $count . ' transaction row(s) after expected rollback.');
        }
    }

    private function cleanupArtifacts(): void
    {
        $this->println('');
        $this->println('Cleanup: enabled');
        try {
            $this->pdo->beginTransaction();

            if ($this->webhookEventId !== null) {
                $this->execute(
                    'DELETE FROM ' . $this->table('webhook_events') . ' WHERE provider = :provider AND event_id = :event_id',
                    [
                        ':provider' => 'invoice',
                        ':event_id' => $this->webhookEventId,
                    ]
                );
            }

            if ($this->idempotencyScope !== null && $this->idempotencyKey !== null) {
                $this->execute(
                    'DELETE FROM ' . $this->table('idempotency_keys') . ' WHERE scope = :scope AND idempotency_key = :idempotency_key',
                    [
                        ':scope' => $this->idempotencyScope,
                        ':idempotency_key' => $this->idempotencyKey,
                    ]
                );
            }

            if ($this->paymentRef !== null) {
                $journalRows = $this->fetchAll(
                    'SELECT id FROM ' . $this->table('ledger_journal') . ' WHERE external_ref = :ref',
                    [':ref' => $this->paymentRef]
                );
                foreach ($journalRows as $journalRow) {
                    $journalId = (int)$journalRow['id'];
                    $this->execute(
                        'DELETE FROM ' . $this->table('ledger_journal') . ' WHERE id = :id',
                        [':id' => $journalId]
                    );
                }

                $this->execute(
                    'DELETE FROM ' . $this->table('payment_intents') . ' WHERE legacy_transaction_ref = :ref',
                    [':ref' => $this->paymentRef]
                );

                $this->execute(
                    'DELETE FROM ' . $this->table('audit_logs') . ' WHERE entity_name = :entity_name AND entity_id = :entity_id',
                    [
                        ':entity_name' => 'transaction',
                        ':entity_id' => $this->paymentRef,
                    ]
                );

                $this->execute(
                    'DELETE FROM ' . $this->table('transaction') . ' WHERE ref = :ref',
                    [':ref' => $this->paymentRef]
                );
            }

            $this->pdo->commit();
            $this->println('Cleanup: done');
        } catch (Throwable $e) {
            if ($this->pdo->inTransaction()) {
                $this->pdo->rollBack();
            }
            $this->println('Cleanup warning: ' . $e->getMessage());
        }
    }

    /** @param callable():void $callable */
    private function runTest(string $name, callable $callable): void
    {
        $this->println('');
        $this->println('[RUN ] ' . $name);
        $started = microtime(true);
        try {
            $callable();
            $durationMs = (int)round((microtime(true) - $started) * 1000);
            $this->results[] = [
                'name' => $name,
                'status' => 'PASS',
                'duration_ms' => $durationMs,
            ];
            $this->println('[PASS] ' . $name . ' (' . $durationMs . 'ms)');
        } catch (Throwable $e) {
            $durationMs = (int)round((microtime(true) - $started) * 1000);
            $this->hasFailure = true;
            $this->results[] = [
                'name' => $name,
                'status' => 'FAIL',
                'duration_ms' => $durationMs,
                'message' => $e->getMessage(),
            ];
            $this->println('[FAIL] ' . $name . ' (' . $durationMs . 'ms) - ' . $e->getMessage());
        }
    }

    private function table(string $suffix): string
    {
        return '`' . $this->prefix . $suffix . '`';
    }

    /** @param array<string, mixed> $params */
    private function execute(string $sql, array $params): void
    {
        $stmt = $this->pdo->prepare($sql);
        $ok = $stmt->execute($params);
        if (!$ok) {
            throw new RuntimeException('SQL execute failed.');
        }
    }

    /**
     * @param array<string, mixed> $params
     * @return array<string, mixed>|null
     */
    private function fetchOne(string $sql, array $params): ?array
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row === false ? null : $row;
    }

    /**
     * @param array<string, mixed> $params
     * @return array<int, array<string, mixed>>
     */
    private function fetchAll(string $sql, array $params): array
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return is_array($rows) ? $rows : [];
    }

    /** @param array<string, mixed> $summary */
    private function writeReport(array $summary, string $path): void
    {
        $dir = dirname($path);
        if (!is_dir($dir)) {
            if (!mkdir($dir, 0777, true) && !is_dir($dir)) {
                throw new RuntimeException('Failed to create report directory: ' . $dir);
            }
        }

        $json = json_encode($summary, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
        if (!is_string($json)) {
            throw new RuntimeException('Failed to encode report JSON.');
        }

        $written = file_put_contents($path, $json);
        if ($written === false) {
            throw new RuntimeException('Failed to write report file: ' . $path);
        }
        $this->println('Report: ' . $path);
    }

    private function println(string $line): void
    {
        if ($line === '' || $this->verbose || str_starts_with($line, '==') || str_starts_with($line, '[RUN') || str_starts_with($line, '[PASS') || str_starts_with($line, '[FAIL') || str_starts_with($line, 'Status:') || str_starts_with($line, 'Tests:') || str_starts_with($line, 'Run ID:') || str_starts_with($line, 'Cleanup:') || str_starts_with($line, 'Brand Context:') || str_starts_with($line, 'DB Prefix:') || str_starts_with($line, 'Report:')) {
            fwrite(STDOUT, $line . PHP_EOL);
        }
    }
}

$cleanupEnabled = true;
$verbose = false;
$reportPath = dirname(__DIR__, 2) . DIRECTORY_SEPARATOR . 'qa' . DIRECTORY_SEPARATOR . 'release_smoke' . DIRECTORY_SEPARATOR . 'reports' . DIRECTORY_SEPARATOR . 'latest.json';

foreach (array_slice($argv, 1) as $arg) {
    if ($arg === '--no-cleanup') {
        $cleanupEnabled = false;
        continue;
    }
    if ($arg === '--verbose') {
        $verbose = true;
        continue;
    }
    if (str_starts_with($arg, '--report=')) {
        $reportPath = substr($arg, strlen('--report='));
        continue;
    }
    if ($arg === '--help' || $arg === '-h') {
        $help = <<<TXT
Usage:
  php qa/release_smoke/run.php [--no-cleanup] [--verbose] [--report=path]

Options:
  --no-cleanup   Keep generated smoke data in DB after run.
  --verbose      Print extra diagnostic output.
  --report=path  Write JSON report to the given path.
TXT;
        fwrite(STDOUT, $help . PHP_EOL);
        exit(0);
    }
}

$runner = new SmokeRunner($cleanupEnabled, $verbose, $reportPath);
exit($runner->run());
