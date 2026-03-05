#!/usr/bin/env python3
import datetime as dt
import json
import subprocess
import uuid
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
TZ = dt.timezone(dt.timedelta(hours=8))


def run(cmd, check=True):
    p = subprocess.run(cmd, capture_output=True, text=True)
    if check and p.returncode != 0:
        raise RuntimeError(f"cmd failed: {' '.join(cmd)}\n{p.stdout}\n{p.stderr}")
    return p


def iso(d):
    return d.astimezone(TZ).isoformat(timespec="seconds")


def parse_candidates(clean_output: str):
    data = json.loads(clean_output)
    return int(data.get("delete_candidates", 0))


def main():
    now = dt.datetime.now(TZ).replace(minute=0, second=0, microsecond=0) + dt.timedelta(days=3)
    start = now
    end = now + dt.timedelta(minutes=30)
    title = f"[回归测试]{uuid.uuid4().hex[:8]}"
    cal = "产品"

    # 1) create
    p1 = run([
        "python3", str(SCRIPT_DIR / "upsert_event.py"),
        "--title", title,
        "--start", iso(start),
        "--end", iso(end),
        "--calendar", cal,
        "--notes", "regression-create",
        "--alarm-minutes", "5",
    ])
    if "CREATED" not in p1.stdout and "UPDATED" not in p1.stdout and "SKIPPED" not in p1.stdout:
        raise RuntimeError("unexpected upsert create output")

    # 2) idempotent
    p2 = run([
        "python3", str(SCRIPT_DIR / "upsert_event.py"),
        "--title", title,
        "--start", iso(start),
        "--end", iso(end),
        "--calendar", cal,
        "--notes", "regression-create",
        "--alarm-minutes", "5",
    ])
    if "SKIPPED" not in p2.stdout and "UPDATED" not in p2.stdout:
        raise RuntimeError("expected SKIPPED/UPDATED in idempotent run")

    # 3) update
    p3 = run([
        "python3", str(SCRIPT_DIR / "upsert_event.py"),
        "--title", title,
        "--start", iso(start),
        "--end", iso(end + dt.timedelta(minutes=15)),
        "--calendar", cal,
        "--notes", "regression-updated",
        "--alarm-minutes", "10",
    ])
    if "UPDATED" not in p3.stdout and "SKIPPED" not in p3.stdout:
        raise RuntimeError("expected UPDATED/SKIPPED in update run")

    # 4) create a deliberate duplicate via legacy add_event
    run([
        "python3", str(SCRIPT_DIR / "add_event.py"),
        "--title", title,
        "--start", iso(start),
        "--end", iso(end + dt.timedelta(minutes=15)),
        "--calendar", cal,
        "--notes", "regression-duplicate",
    ])

    range_start = iso(start - dt.timedelta(hours=1))
    range_end = iso(end + dt.timedelta(hours=2))
    snapshot_path = SCRIPT_DIR.parent / "tmp-regression-delete-plan.json"

    # 5) clean dry-run should find duplicate
    c1 = run([
        "python3", str(SCRIPT_DIR / "calendar_clean.py"),
        "--start", range_start,
        "--end", range_end,
        "--snapshot-out", str(snapshot_path),
    ])
    cand1 = parse_candidates(c1.stdout)
    if cand1 < 1:
        raise RuntimeError("expected duplicate candidates >= 1")

    # 6) apply with confirm
    run([
        "python3", str(SCRIPT_DIR / "calendar_clean.py"),
        "--start", range_start,
        "--end", range_end,
        "--apply", "--confirm", "yes",
    ])

    # 7) verify candidates reduced to 0 for this narrow window
    c2 = run([
        "python3", str(SCRIPT_DIR / "calendar_clean.py"),
        "--start", range_start,
        "--end", range_end,
    ])
    cand2 = parse_candidates(c2.stdout)
    if cand2 != 0:
        raise RuntimeError(f"expected duplicate candidates 0 after cleanup, got {cand2}")

    print(json.dumps({
        "ok": True,
        "title": title,
        "range": {"start": range_start, "end": range_end},
        "snapshot": str(snapshot_path),
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
