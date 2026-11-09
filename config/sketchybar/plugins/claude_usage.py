#!/usr/bin/env python3

import json, os, shutil, subprocess, sys, urllib.request
from datetime import datetime, timezone

NAME = os.environ.get("NAME", "claude_usage")
SENDER = os.environ.get("SENDER", "")
ARG = sys.argv[1] if len(sys.argv) > 1 else ""

CACHE_FILE = os.path.expanduser("~/.claude/.usage-cache.json")
CACHE_TTL = 120
WINDOW_SEC = 5 * 3600

CLAUDE_BIN = shutil.which("claude") or os.path.expanduser("~/.local/bin/claude")
SESSION_PREFIX = f"{NAME}.popup.session."
SESSION_COLORS = {"busy": "0xffa6e3a1", "idle": "0xff666666"}
SESSION_OTHER_COLOR = "0xffffaa66"


def sketchybar(*args):
    subprocess.run(["sketchybar"] + list(args))


def set_item(name: str, props: dict):
    args = [f"{k}={v}" for k, v in props.items()]
    sketchybar("--set", name, *args)


def inactive():
    set_item(NAME, {"label": f"--{session_suffix}", "label.color": "0xff555555"})
    sys.exit()


def get_sessions():
    try:
        result = subprocess.run(
            [CLAUDE_BIN, "agents", "--json"],
            capture_output=True, text=True, timeout=5,
        )
        return json.loads(result.stdout) if result.returncode == 0 else []
    except Exception:
        return []


def existing_session_items():
    result = subprocess.run(["sketchybar", "--query", NAME], capture_output=True, text=True)
    try:
        items = json.loads(result.stdout)["popup"]["items"]
    except Exception:
        return set()
    return {i for i in items if i.startswith(SESSION_PREFIX)}


def update_sessions(sessions):
    busy = sum(1 for s in sessions if s.get("status") == "busy")
    set_item(f"{NAME}.popup.sessions", {
        "label": f"Sessions  {busy} busy / {len(sessions)}",
    })

    wanted = {f"{SESSION_PREFIX}{s['pid']}": s for s in sessions}
    existing = existing_session_items()
    for item in existing - wanted.keys():
        sketchybar("--remove", item)

    now_ms = datetime.now(timezone.utc).timestamp() * 1000
    for item, s in sorted(wanted.items(), key=lambda kv: kv[1].get("startedAt", 0)):
        status = s.get("status", "?")
        age = fmt_duration(int((now_ms - s.get("startedAt", now_ms)) / 1000))
        name = s.get("name") or os.path.basename(s.get("cwd", ""))
        if item not in existing:
            sketchybar(
                "--add", "item", item, f"popup.{NAME}",
                "--set", item,
                "icon=●",
                "icon.font=Hack Nerd Font:Bold:12.0",
                "icon.padding_left=14",
                "icon.padding_right=6",
                "label.font=Hack Nerd Font:Bold:13.0",
                "label.color=0xffaaaaaa",
                "label.padding_right=12",
            )
        set_item(item, {
            "icon.color": SESSION_COLORS.get(status, SESSION_OTHER_COLOR),
            "label": f"{name}   {status} · {age}",
        })
    return busy


def read_cache():
    try:
        with open(CACHE_FILE) as f:
            cache = json.load(f)
        age = (datetime.now(timezone.utc) - datetime.fromisoformat(cache["fetched_at"])).total_seconds()
        if age < CACHE_TTL:
            return cache["data"]
    except Exception:
        pass
    return None


def write_cache(data):
    try:
        with open(CACHE_FILE, "w") as f:
            json.dump({"fetched_at": datetime.now(timezone.utc).isoformat(), "data": data}, f)
    except Exception:
        pass


def get_access_token():
    result = subprocess.run(
        ["security", "find-generic-password", "-s", "Claude Code-credentials", "-w"],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        return None
    creds = json.loads(result.stdout.strip())
    return creds.get("claudeAiOauth", creds).get("accessToken")


def fetch_usage(token):
    req = urllib.request.Request(
        "https://api.anthropic.com/api/oauth/usage",
        headers={
            "Authorization": f"Bearer {token}",
            "anthropic-beta": "oauth-2025-04-20",
            "Content-Type": "application/json",
        },
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.loads(resp.read())


def tier(burn: float, pct: float) -> tuple[str, str, str]:
    """Returns (tier_name, warn_glyph, label_color_hex)."""
    if burn > 2.0 or pct >= 90:
        return "PANIC", "", "0xffff8888"
    if burn > 1.3 or pct >= 75:
        return "ANXIOUS", "", "0xffffaa66"
    if burn > 1.0 or pct >= 50:
        return "CAUTION", "", "0xffffffff"
    return "CALM", "", "0xffffffff"


def progress_bar(pct: float, width: int = 20) -> str:
    filled = round(pct / 100 * width)
    return "█" * filled + "░" * (width - filled)


def fmt_duration(seconds: int) -> str:
    h, m = seconds // 3600, (seconds % 3600) // 60
    return f"{h}h{m:02d}m" if h > 0 else f"{m}m"


def update_popup(pct, remaining, elapsed, burn, exhaust_sec):
    bar = progress_bar(pct)
    elapsed_h, elapsed_m = elapsed // 3600, (elapsed % 3600) // 60
    window_total_h = WINDOW_SEC // 3600

    set_item(f"{NAME}.popup.bar", {
        "label": f"{bar}  {pct:.0f}%",
    })
    set_item(f"{NAME}.popup.window", {
        "label": f"{elapsed_h}h{elapsed_m:02d}m elapsed  /  {window_total_h}h window",
    })
    set_item(f"{NAME}.popup.resets", {
        "label": f"Resets in  {fmt_duration(remaining)}",
    })

    if burn > 0:
        tier_name, _, burn_color = tier(burn, pct)
        burn_label = f"{burn:.2f}x   {tier_name}"
        if 0 < exhaust_sec < remaining:
            burn_label += f"   exhausts in {fmt_duration(exhaust_sec)}"
        set_item(f"{NAME}.popup.burn", {
            "label": burn_label,
            "label.color": burn_color,
        })
    else:
        set_item(f"{NAME}.popup.burn", {
            "label": "—   CALM  (warming up)",
            "label.color": "0xff666666",
        })


# --- close popup on mouse exit or focus change ---
if SENDER in ("mouse.exited.global", "front_app_switched", "space_change"):
    sketchybar("--set", "claude_usage", "popup.drawing=off")
    sys.exit()

# --- sessions ---
sessions = get_sessions()
busy_count = update_sessions(sessions)
session_suffix = f"  󰚩 {busy_count}/{len(sessions)}" if sessions else ""

# --- fetch data ---
data = read_cache()
if not data:
    token = get_access_token()
    if not token:
        inactive()
    try:
        data = fetch_usage(token)
        write_cache(data)
    except Exception:
        inactive()

fh = data.get("five_hour")
if not fh:
    inactive()

# --- calculate ---
pct = fh["utilization"]
resets_at = datetime.fromisoformat(fh["resets_at"])
now = datetime.now(timezone.utc)
remaining = max(0, int((resets_at - now).total_seconds()))
elapsed = max(0, WINDOW_SEC - remaining)

if elapsed >= 900 and pct >= 1:
    burn = (pct / 100.0) / (elapsed / WINDOW_SEC)
    rate_per_sec = (pct / 100.0) / elapsed
    exhaust_sec = int((1.0 - pct / 100.0) / rate_per_sec) if pct < 100 and rate_per_sec > 0 else 0
else:
    burn = 0.0
    exhaust_sec = 0

_, warn_glyph, label_color = tier(burn, pct)

warn = ""
if 0 < exhaust_sec < remaining:
    warn = f"  {warn_glyph} {fmt_duration(exhaust_sec)}"

# --- toggle popup ---
if ARG == "toggle_popup":
    sketchybar("--set", "claude_usage", "popup.drawing=toggle")
    update_popup(pct, remaining, elapsed, burn, exhaust_sec)
    sys.exit()

# --- regular update ---
label = f"{pct:.0f}%  {fmt_duration(remaining)}{warn}{session_suffix}"
set_item(NAME, {"label": label, "label.color": label_color})
update_popup(pct, remaining, elapsed, burn, exhaust_sec)
