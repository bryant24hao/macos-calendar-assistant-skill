#!/bin/zsh
set -euo pipefail

( crontab -l 2>/dev/null || true ) | sed '/calendar_clean_notify.sh/d' > /tmp/macos_calendar_assistant_cron_remove
crontab /tmp/macos_calendar_assistant_cron_remove

echo "Removed calendar_clean_notify.sh cron job."
