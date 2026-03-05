# Test Plan (macos-calendar-assistant)

## Scope
Validate safe calendar operations for local use before external release.

## Regression checklist (manual)

1. **List calendars**
   - Command: `swift scripts/list_calendars.swift`
   - Expect: valid JSON + at least 1 writable calendar.

2. **List events**
   - Command: `swift scripts/list_events.swift <start> <end>`
   - Expect: valid JSON with `events` array.

3. **Upsert create (dry-run)**
   - Command: `python3 scripts/upsert_event.py ... --dry-run`
   - Expect: `DRYRUN action=create` OR `DRYRUN action=update`.

4. **Upsert idempotency**
   - Run same upsert twice (without dry-run).
   - Expect: first `CREATED`, second `SKIPPED` (or `UPDATED` if payload changed).

5. **Upsert update path**
   - Change notes/location/end time, run again.
   - Expect: `UPDATED`.

6. **Alarm set**
   - Command: `python3 scripts/set_alarm.py --uid <uid> --alarm-minutes 15`
   - Expect: success message.

7. **Duplicate scan (dry-run)**
   - Command: `python3 scripts/calendar_clean.py --start ... --end ...`
   - Expect: JSON with `delete_candidates` field.

8. **Duplicate cleanup apply**
   - Command: `python3 scripts/calendar_clean.py --start ... --end ... --apply`
   - Expect: `removed=<n>` when candidates exist.

9. **Cron notifier install**
   - Command: `scripts/install.sh`
   - Expect: cron entry with `calendar_clean_notify.sh`.

10. **Uninstall**
   - Command: `scripts/uninstall.sh`
   - Expect: cron entry removed.

## Smoke test
Run:
```bash
scripts/smoke_test.sh
```
