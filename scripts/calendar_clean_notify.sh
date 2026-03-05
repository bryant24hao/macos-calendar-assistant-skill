#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_PATH="${CAL_SKILL_CONFIG:-$SKILL_DIR/config.json}"

# Defaults
LOOKBACK_DAYS=1
LOOKAHEAD_DAYS=0
OUT_DIR="$HOME/clawd/memory"
NOTIFY_ENABLED=true
NOTIFY_TITLE="MemoryXBOT 日程提醒"

if [[ -f "$CONFIG_PATH" ]]; then
  eval "$(/usr/bin/python3 - <<'PY' "$CONFIG_PATH"
import json,sys,os
p=sys.argv[1]
try:
  cfg=json.load(open(p))
except Exception:
  cfg={}

print(f'LOOKBACK_DAYS={int(cfg.get("lookback_days",1))}')
print(f'LOOKAHEAD_DAYS={int(cfg.get("lookahead_days",0))}')
out=cfg.get('output_dir','~/clawd/memory')
print('OUT_DIR=' + json.dumps(os.path.expanduser(out)))
notify=cfg.get('notification',{}) if isinstance(cfg.get('notification',{}),dict) else {}
print('NOTIFY_ENABLED=' + ('true' if notify.get('enabled',True) else 'false'))
print('NOTIFY_TITLE=' + json.dumps(str(notify.get('title','MemoryXBOT 日程提醒'))))
PY
)"
fi

mkdir -p "$OUT_DIR"
OUT="$OUT_DIR/calendar-clean-last.json"
ALERT="$OUT_DIR/calendar-clean-alert.txt"

START=$(/bin/date -v-${LOOKBACK_DAYS}d +%Y-%m-%d)T00:00:00+08:00
END=$(/bin/date -v+${LOOKAHEAD_DAYS}d +%Y-%m-%d)T23:59:59+08:00

/usr/bin/python3 "$SCRIPT_DIR/calendar_clean.py" --start "$START" --end "$END" > "$OUT" 2>&1 || true

CANDIDATES=$(/usr/bin/python3 - <<'PY' "$OUT"
import json,sys
try:
    data=json.load(open(sys.argv[1]))
    print(int(data.get('delete_candidates',0)))
except Exception:
    print(0)
PY
)

if [[ "$CANDIDATES" -gt 0 ]]; then
  MSG="Calendar发现 ${CANDIDATES} 条重复候选，建议清理"
  echo "$(date '+%Y-%m-%d %H:%M:%S') $MSG" > "$ALERT"
  if [[ "$NOTIFY_ENABLED" == "true" ]]; then
    /usr/bin/osascript -e "display notification \"$MSG\" with title \"$NOTIFY_TITLE\""
  fi
fi
