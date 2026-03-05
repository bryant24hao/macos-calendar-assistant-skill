# macos-calendar-assistant

> macOS Calendar.app automation skill with idempotent writes, duplicate cleanup, and daily checks.

English | [中文](#中文)

---

## English

### What it does
- List calendars and events
- Idempotent event write (`CREATED` / `UPDATED` / `SKIPPED`)
- Set event alarms by UID
- Detect and clean duplicates
- Daily duplicate-check notification via cron

### Requirements
- macOS
- Python 3.9+
- Swift (Xcode Command Line Tools)
- Calendar permission granted to terminal/host process

### Quick start
```bash
cd scripts
./install.sh
```

### Core commands
```bash
# Environment check
python3 scripts/env_check.py

# Idempotent create/update
python3 scripts/upsert_event.py \
  --title "Team sync" \
  --start "2026-03-06T19:00:00+08:00" \
  --end "2026-03-06T20:00:00+08:00" \
  --calendar "工作" \
  --notes "Agenda" \
  --alarm-minutes 15

# Duplicate scan (dry-run)
python3 scripts/calendar_clean.py --start "2026-03-01T00:00:00+08:00" --end "2026-03-08T23:59:59+08:00"

# Duplicate cleanup (double confirmation)
python3 scripts/calendar_clean.py --start "..." --end "..." --apply --confirm yes --snapshot-out ./delete-plan.json

# Tests
scripts/smoke_test.sh
python3 scripts/regression_test.py
```

### Uninstall
```bash
cd scripts
./uninstall.sh
```

---

## 中文

### 功能
- 列出日历与事件
- 幂等写入事件（`CREATED` / `UPDATED` / `SKIPPED`）
- 按 UID 设置提醒
- 检测并清理重复事件
- 通过 cron 每日自动检查重复并提醒

### 环境要求
- macOS
- Python 3.9+
- Swift（Xcode Command Line Tools）
- 终端/宿主进程已授予 Calendar 权限

### 快速开始
```bash
cd scripts
./install.sh
```

### 核心命令
```bash
# 环境自检
python3 scripts/env_check.py

# 幂等创建/更新
python3 scripts/upsert_event.py \
  --title "团队同步" \
  --start "2026-03-06T19:00:00+08:00" \
  --end "2026-03-06T20:00:00+08:00" \
  --calendar "工作" \
  --notes "议程" \
  --alarm-minutes 15

# 重复扫描（仅检查，不删除）
python3 scripts/calendar_clean.py --start "2026-03-01T00:00:00+08:00" --end "2026-03-08T23:59:59+08:00"

# 重复清理（双保险确认）
python3 scripts/calendar_clean.py --start "..." --end "..." --apply --confirm yes --snapshot-out ./delete-plan.json

# 测试
scripts/smoke_test.sh
python3 scripts/regression_test.py
```

### 卸载
```bash
cd scripts
./uninstall.sh
```
