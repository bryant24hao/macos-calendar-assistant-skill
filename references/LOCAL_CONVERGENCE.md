# Local Convergence Checklist (Bryant workspace)

Goal: keep one local, stable skill for daily use before any public release work.

## Canonical skill
- `skills/macos-calendar-assistant`

## Current convergence status
- [x] `within_2h.py` merged into canonical skill
- [x] HEARTBEAT uses canonical path
- [x] Old `skills/macos-calendar/within_2h.py` replaced with compatibility wrapper
- [x] Daily cleanup cron uses canonical notify script
- [x] Smoke test passes
- [x] Regression test passes

## Before public-release work
- [ ] Run 3–5 days of real daily usage with no critical issues
- [ ] Collect local usage notes (what to simplify / what confuses users)
- [ ] Freeze local command surface (avoid breaking changes)
- [ ] Tag local stable point (v0.1.0-local)
