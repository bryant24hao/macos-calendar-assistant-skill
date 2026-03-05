---
name: macos-calendar-assistant
description: Manage macOS Calendar.app events with deterministic scripts (list calendars/events, idempotent create-or-update, alarms, duplicate cleanup, and daily cleanup notifications). Use when asked to add/reschedule/edit calendar events, set reminders, review schedule conflicts, or clean duplicate events in Calendar.app.
---

# macos-calendar-assistant

Use bundled scripts for reliable Calendar.app operations.

## Workflow

1. Extract title, start/end, timezone, calendar, location, notes, alarm.
2. Check conflicts before writing:
   - `scripts/list_events.swift <start_iso> <end_iso>`
3. Prefer idempotent writes:
   - `scripts/upsert_event.py` (create/update/skip)
4. Apply alarm if requested:
   - `scripts/set_alarm.py --uid <event_uid> --alarm-minutes <n>`
5. For hygiene, run duplicate scan:
   - `scripts/calendar_clean.py --start <iso> --end <iso>`

## Calendar routing defaults

- 运动/跑步/训练 → `Training`
- 工作/会议/客户 → `工作`
- 产品/开发/MemoryX → `产品`
- 生活/聚会/旅行 → `生活`
- If unspecified: prefer writable iCloud/CalDAV calendars over local calendars.

## Commands

### List calendars
```bash
swift scripts/list_calendars.swift
```

### List events in range
```bash
swift scripts/list_events.swift "2026-03-06T00:00:00+08:00" "2026-03-06T23:59:59+08:00"
```

Output includes `uid` for follow-up alarm/edit operations.

### Idempotent create/update (recommended)
```bash
python3 scripts/upsert_event.py \
  --title "Team sync" \
  --start "2026-03-06T19:00:00+08:00" \
  --end "2026-03-06T20:00:00+08:00" \
  --calendar "工作" \
  --notes "Agenda" \
  --location "Online" \
  --alarm-minutes 15
```

Result is one of: `CREATED`, `UPDATED`, `SKIPPED`.
Use `--dry-run` for preview.

### Legacy direct add (always creates)
```bash
python3 scripts/add_event.py --title "..." --start "..." --end "..."
```

### Set alarm by UID
```bash
python3 scripts/set_alarm.py --uid "EVENT_UID" --alarm-minutes 15
```

### Move event (legacy utility)
```bash
swift scripts/move_event.swift "Team sync" "工作" "2026-03-07T10:00:00+08:00" 60 --search-days 7
# optional precise match:
# --original-start "2026-03-06T10:00:00+08:00"
```
Prefer `upsert_event.py` for most rescheduling flows; use `move_event.swift` for direct title-based move when needed.

### Duplicate scan / cleanup
```bash
python3 scripts/calendar_clean.py --start "2026-03-01T00:00:00+08:00" --end "2026-03-08T23:59:59+08:00"
python3 scripts/calendar_clean.py --start "..." --end "..." --apply --confirm yes --snapshot-out ./delete-plan.json
```

### Environment + tests
```bash
python3 scripts/env_check.py
python3 scripts/regression_test.py
scripts/smoke_test.sh
```

### Daily auto-check notifier
```bash
scripts/install.sh     # run env check + install cron from config.json
scripts/uninstall.sh   # remove cron
```

## Constraints

- macOS only (EventKit + Calendar permission required)
- Default timezone comes from `config.json.timezone` (fallback Asia/Shanghai) when user does not specify
- Use `--apply` only after reviewing dry-run output
