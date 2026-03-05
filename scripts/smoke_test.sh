#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[1/4] list_calendars.swift"
swift "$SCRIPT_DIR/list_calendars.swift" >/tmp/mca_calendars.json

echo "[2/4] list_events.swift"
swift "$SCRIPT_DIR/list_events.swift" "2026-03-06T00:00:00+08:00" "2026-03-06T23:59:59+08:00" >/tmp/mca_events.json

echo "[3/4] upsert_event.py --dry-run"
python3 "$SCRIPT_DIR/upsert_event.py" \
  --title "[测试] mca smoke" \
  --start "2026-03-09T10:00:00+08:00" \
  --end "2026-03-09T10:30:00+08:00" \
  --calendar "产品" \
  --notes "smoke" \
  --alarm-minutes 10 \
  --dry-run >/tmp/mca_upsert.txt

echo "[4/4] calendar_clean.py"
python3 "$SCRIPT_DIR/calendar_clean.py" \
  --start "2026-03-02T00:00:00+08:00" \
  --end "2026-03-09T00:00:00+08:00" >/tmp/mca_clean.json

echo "---- smoke outputs ----"
cat /tmp/mca_upsert.txt
python3 - <<'PY'
import json
for p in ['/tmp/mca_calendars.json','/tmp/mca_events.json','/tmp/mca_clean.json']:
    try:
        json.load(open(p))
        print('OK JSON', p)
    except Exception as e:
        print('BAD JSON', p, e)
        raise
print('SMOKE_TEST_OK')
PY
