# v0.1.0-beta

Initial public beta of `macos-calendar-assistant`.

## Highlights
- IM-first calendar operations via OpenClaw workflows
- Idempotent event write (`CREATED` / `UPDATED` / `SKIPPED`)
- Safe duplicate cleanup (`--apply --confirm yes` + snapshot)
- Screenshot-to-schedule friendly workflow
- Daily duplicate-check notifier
- Local convergence + re-audit pass completed

## Included capabilities
- list calendars/events
- create/update events
- move event utility
- alarm update by uid
- duplicate scan/cleanup
- env check + smoke + regression tests

## Safety and reliability
- explicit deletion confirmation
- timezone/config utilities
- dedup preferences configurable
- local test suite passing

## Known boundaries
- macOS/EventKit only
- calendar names vary by user setup (intent mapping required)

## Recommended usage
- Start with `scripts/install.sh`
- Run `scripts/smoke_test.sh`
- Use `upsert_event.py` for most writes
