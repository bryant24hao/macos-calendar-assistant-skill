# Re-Audit Result (Local Convergence)

Date: 2026-03-05
Scope: `skills/macos-calendar-assistant`
Goal: close all critical findings from prior audit and confirm local-stable readiness.

## Summary Verdict

- Local-stable status: **PASS**
- Critical regressions: **none found**
- Test status: **env/smoke/regression all passing**

## Findings Closure Map

| Item | Status | Notes |
|---|---|---|
| move_event search window too narrow | ✅ Resolved | Added wider search (`--search-days`) + precise anchor (`--original-start`). |
| move_event undocumented | ✅ Resolved | Added usage section in `SKILL.md`. |
| timezone hardcoding (`+08:00`) | ✅ Resolved | Timezone now read from config/system fallback path in scripts. |
| list_calendars redundancy confusion | ✅ Resolved | `list_calendars.py` converted to deprecated shim delegating to Swift canonical script. |
| smoke test static dates | ✅ Resolved | `smoke_test.sh` now uses dynamic dates. |
| dedup calendar hardcoding | ✅ Resolved | Moved to `config` (`dedup.prefer_calendars`, `dedup.deprioritize_calendars`). |
| regression test residue | ✅ Resolved | Added post-run cleanup path and temp snapshot usage. |
| tracked temp artifact risk | ✅ Resolved | Regression snapshot moved to temp dir; stale tracked temp removed. |
| notify script `eval` fragility | ✅ Resolved | Replaced with field-by-field parsing; no eval usage. |
| list_events missing uid | ✅ Resolved | `uid` included in output for follow-up operations. |

## Key Commits (latest remediation)

- `5df9561` — fix: address audit findings on timezone, dedup safety, tests, and docs
- `6553b97` — docs: update local convergence note and make env_check executable
- `fa01e67` — fix: add within_2h docs to SKILL.md, clean up smoke test temp files
- `887cb0e` — fix: remediation pass – temp file leaks, calendar permissions, timezone fallback

## Validation Evidence

Executed after remediation:

- `python3 scripts/env_check.py` → `ok: true`
- `scripts/smoke_test.sh` → `SMOKE_TEST_OK`
- `python3 scripts/regression_test.py` → `ok: true`

## Remaining Known Boundaries (non-blocking)

- macOS/EventKit dependency remains by design (not cross-platform).
- ACP secondary re-review transcript visibility may vary by runtime/session policy, but local code/test validation is complete.

## Release Recommendation

- Current state is suitable for:
  - continued local production use
  - small beta circulation
- For public release packaging, proceed with a separate publishing pass (docs polish, marketing copy, release tags).
