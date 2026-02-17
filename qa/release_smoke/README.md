# WS-6 Release Smoke Suite

এই suite টি release gate-এর critical integration checks automate করে।

## কী কী টেস্ট করে

1. `IDEMPOTENCY_REPLAY`
2. `DUPLICATE_WEBHOOK`
3. `LEDGER_INVARIANT` (journal debit = credit)
4. `ROLLBACK_PARTIAL_FAILURE`

## Prerequisites

1. Installer complete হতে হবে।
2. `pp-config.php` (বা `pp-temp-config.php`) থাকতে হবে।
3. Fintech schema tables present হতে হবে।
4. PHP CLI থেকে project root-এ command run করতে হবে।

## Run

```bash
php qa/release_smoke/run.php
```

## Useful Options

```bash
php qa/release_smoke/run.php --no-cleanup
php qa/release_smoke/run.php --verbose
php qa/release_smoke/run.php --report=qa/release_smoke/reports/run-001.json
```

## Output

- Console-এ test-by-test `PASS/FAIL`
- JSON report (default): `qa/release_smoke/reports/latest.json`

## Safety Note

- Default mode cleanup enabled: test-created rows run শেষে remove করা হয়।
- `--no-cleanup` দিলে generated test rows DB-তে থাকবে।
- Recommended target: staging/pre-prod DB.
