#!/usr/bin/env python3
"""Codex notification hook that bridges Codex events to codex-notify."""

import json
import os
import shutil
import subprocess
import sys
from typing import Any, Dict, Optional


SOUND_FILES = [
    "/usr/share/sounds/freedesktop/stereo/complete.oga",
    "/usr/share/sounds/freedesktop/stereo/message.oga",
    "/usr/share/sounds/freedesktop/stereo/bell.oga",
]


def play_sound() -> None:
    """Play a short sound as a fallback notification."""

    sound_path: Optional[str] = None
    for sound in SOUND_FILES:
        if os.path.exists(sound):
            sound_path = sound
            break

    try:
        if sound_path:
            try:
                subprocess.Popen(
                    ["paplay", "--volume=98304", sound_path],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                return
            except FileNotFoundError:
                try:
                    subprocess.Popen(
                        ["aplay", "-q", sound_path],
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                    )
                    return
                except FileNotFoundError:
                    pass

        print("\a", end="", flush=True)
    except Exception:
        pass


def resolve_notify_cli() -> Optional[str]:
    """Locate the codex-notify executable."""

    candidates = []

    env_path = os.environ.get("CODEX_NOTIFY_BIN")
    if env_path:
        candidates.append(os.path.expanduser(env_path))

    cli_path = shutil.which("codex-notify")
    if cli_path:
        candidates.append(cli_path)

    candidates.append(os.path.expanduser("~/bin/codex-notify"))
    candidates.append(
        os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "bin", "codex-notify"))
    )

    for candidate in candidates:
        if candidate and os.path.exists(candidate):
            return candidate

    return None


def send_via_cli(title: str, message: str, notif_type: str = "info", persistent: bool = False) -> bool:
    """Send a notification through codex-notify; return True on success."""

    cli = resolve_notify_cli()
    if not cli:
        return False

    args = [cli, "send", title, message, notif_type, "true" if persistent else "false"]

    try:
        subprocess.run(args, check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=5)
        return True
    except Exception:
        return False


def handle_notification_event(event: Dict[str, Any]) -> bool:
    """Handle a Codex notification event; returns True if handled."""

    reason = str(event.get("reason") or "")
    severity = str(event.get("severity") or event.get("level") or "").lower()

    title = event.get("title") or ""
    message = event.get("message") or event.get("body") or event.get("description") or ""

    notif_type = "info"
    persistent = False

    reason_lower = reason.lower()

    if any(keyword in reason_lower for keyword in ("permission", "approval", "allow", "confirm")):
        notif_type = "approval"
        persistent = True
        if not title:
            title = "Codex Needs Approval"
        if not message:
            message = "Switch to your Codex terminal to approve the request."
    elif "idle" in reason_lower or "waiting" in reason_lower:
        notif_type = "info"
        if not title:
            title = "Codex Waiting"
        if not message:
            idle_seconds = event.get("idle_seconds") or event.get("idle_duration") or event.get("idle_duration_sec")
            if idle_seconds:
                message = f"Codex has been idle for {idle_seconds} seconds."
            else:
                message = "Codex has been waiting for your input."
    elif severity == "error":
        notif_type = "error"
        if not title:
            title = "Codex Error"
    elif severity in {"success", "ok", "completed", "complete"}:
        notif_type = "success"
        if not title:
            title = "Codex Complete"

    if not title:
        title = "Codex Notification"

    if not message:
        message = reason or "Codex sent a notification."

    return send_via_cli(str(title), str(message), notif_type, persistent)


def main() -> int:
    if len(sys.argv) != 2:
        return 0

    try:
        event = json.loads(sys.argv[1])
    except Exception:
        return 0

    event_type = str(event.get("type") or "").lower()

    if event_type == "notification":
        handled = handle_notification_event(event)
        if not handled:
            play_sound()
        return 0

    if event_type in {"agent-turn-complete", "turn-complete"}:
        play_sound()
        return 0

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
