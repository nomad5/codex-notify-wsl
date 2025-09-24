#!/usr/bin/env python3
"""
Minimal notifier for Codex "notify" hook.
Plays a system sound when an agent turn completes.

Usage: Codex runs this script with a single JSON argument.
"""

import json
import os
import subprocess
import sys


def main() -> int:
    if len(sys.argv) != 2:
        return 0

    try:
        event = json.loads(sys.argv[1])
    except Exception:
        event = {}

    if event.get("type") != "agent-turn-complete":
        return 0

    # Linux system sounds - try multiple options
    sound_files = [
        "/usr/share/sounds/freedesktop/stereo/complete.oga",
        "/usr/share/sounds/freedesktop/stereo/message.oga",
        "/usr/share/sounds/freedesktop/stereo/bell.oga",
    ]

    # Find first available sound file
    sound_path = None
    for sound in sound_files:
        if os.path.exists(sound):
            sound_path = sound
            break

    try:
        if sound_path:
            # Try paplay (PulseAudio) first, then aplay (ALSA)
            # Volume set to 150% (1.5x louder)
            try:
                subprocess.Popen(["paplay", "--volume=98304", sound_path],  # 150% = 98304 (65536 * 1.5)
                                stdout=subprocess.DEVNULL,
                                stderr=subprocess.DEVNULL)
            except FileNotFoundError:
                try:
                    subprocess.Popen(["aplay", "-q", sound_path],
                                    stdout=subprocess.DEVNULL,
                                    stderr=subprocess.DEVNULL)
                except FileNotFoundError:
                    # Fall back to terminal bell
                    print("\a", end="", flush=True)
        else:
            # No sound files found, use terminal bell
            print("\a", end="", flush=True)
    except Exception:
        pass

    return 0


if __name__ == "__main__":
    raise SystemExit(main())