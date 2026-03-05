#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
from zoneinfo import ZoneInfo


def skill_root() -> Path:
    return Path(__file__).resolve().parent.parent


def config_path() -> Path:
    return skill_root() / "config.json"


def load_config() -> dict:
    p = config_path()
    if not p.exists():
        return {}
    try:
        return json.loads(p.read_text())
    except Exception:
        return {}


def get_timezone_name(default: str = "Asia/Shanghai") -> str:
    cfg = load_config()
    return str(cfg.get("timezone", default))


def get_zoneinfo(default: str = "Asia/Shanghai") -> ZoneInfo:
    try:
        return ZoneInfo(get_timezone_name(default))
    except Exception:
        return ZoneInfo(default)
