#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

VALS=(${(s: :)$(python3 - <<'PY' "$SCRIPT_DIR"
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo
from pathlib import Path
import json,sys
script_dir=Path(sys.argv[1])
cfg={}
cp=script_dir.parent/'config.json'
if cp.exists():
    try: cfg=json.loads(cp.read_text())
    except: cfg={}
tz=ZoneInfo(cfg.get('timezone','Asia/Shanghai'))
now=datetime.now(tz).replace(second=0,microsecond=0)
day=(now+timedelta(days=1)).strftime('%Y-%m-%d')
start_day=f"{day}T00:00:00{now.strftime('%z')[:3]}:{now.strftime('%z')[3:]}"
end_day=f"{day}T23:59:59{now.strftime('%z')[:3]}:{now.strftime('%z')[3:]}"
up_start=(now+timedelta(days=2)).replace(hour=10,minute=0)
up_end=up_start+timedelta(minutes=30)
clean_start=(now-timedelta(days=3)).replace(hour=0,minute=0)
clean_end=(now+timedelta(days=3)).replace(hour=23,minute=59)
fmt=lambda d:d.isoformat(timespec='seconds')
print(start_day, end_day, fmt(up_start), fmt(up_end), fmt(clean_start), fmt(clean_end))
PY
)})

START_DAY=${VALS[1]}
END_DAY=${VALS[2]}
UPSERT_START=${VALS[3]}
UPSERT_END=${VALS[4]}
CLEAN_START=${VALS[5]}
CLEAN_END=${VALS[6]}

echo "[1/4] list_calendars.swift"
swift "$SCRIPT_DIR/list_calendars.swift" >/tmp/mca_calendars.json

echo "[2/4] list_events.swift"
swift "$SCRIPT_DIR/list_events.swift" "$START_DAY" "$END_DAY" >/tmp/mca_events.json

echo "[3/4] upsert_event.py --dry-run"
python3 "$SCRIPT_DIR/upsert_event.py" \
  --title "[测试] mca smoke" \
  --start "$UPSERT_START" \
  --end "$UPSERT_END" \
  --calendar "产品" \
  --notes "smoke" \
  --alarm-minutes 10 \
  --dry-run >/tmp/mca_upsert.txt

echo "[4/4] calendar_clean.py"
python3 "$SCRIPT_DIR/calendar_clean.py" \
  --start "$CLEAN_START" \
  --end "$CLEAN_END" >/tmp/mca_clean.json

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
