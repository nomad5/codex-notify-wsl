#!/usr/bin/env bash
# Codex Notification Configuration
# Edit this file to customize notification behavior

# Notification method preference
# Options: auto, burnttoast, snoretoast, msg, bell
# auto = automatically detect best available method
CODEX_NOTIFY_METHOD="auto"

# Enable/disable notification sounds
# true = play sounds with notifications
# false = silent notifications only
CODEX_NOTIFY_SOUND="true"

# Make all notifications persistent by default
# true = notifications stay until dismissed
# false = notifications auto-dismiss after timeout
CODEX_NOTIFY_PERSISTENT="false"

# Enable debug logging
# true = verbose logging to console and file
# false = minimal logging to file only
CODEX_NOTIFY_DEBUG="false"

# Completely disable notifications
# true = no notifications at all
# false = notifications enabled
CODEX_NOTIFY_DISABLE="false"

# Custom patterns to watch for (pipe-separated regex)
# Example: "custom alert|special event|my pattern"
CODEX_NOTIFY_PATTERNS=""

# Notification timeouts (in seconds)
# How long before considering a task "long-running"
LONG_TASK_THRESHOLD=60

# Sound file paths (Linux side)
SOUND_SUCCESS="/usr/share/sounds/freedesktop/stereo/complete.oga"
SOUND_ERROR="/usr/share/sounds/freedesktop/stereo/dialog-error.oga"
SOUND_WARNING="/usr/share/sounds/freedesktop/stereo/dialog-warning.oga"

# Windows notification app ID (for grouping notifications)
WINDOWS_APP_ID="Codex"

# Log file settings
MAX_LOG_SIZE=10485760  # 10MB in bytes
ROTATE_LOGS="true"     # Rotate logs when they get too large

# Notification priorities for different event types
# Higher priority notifications are more likely to break through Focus Assist
PRIORITY_APPROVAL="high"
PRIORITY_ERROR="high"
PRIORITY_SUCCESS="normal"
PRIORITY_INFO="low"

# Custom notification titles (customize how notifications appear)
# Note: Emojis are automatically added by the wrapper based on type
TITLE_APPROVAL="Codex Approval Required"
TITLE_ERROR="Codex Error"
TITLE_SUCCESS="Codex Complete"
TITLE_INFO="Codex Info"
TITLE_WARNING="Codex Warning"
TITLE_LONG_RUN="Codex Long-Running Task"

# Enable/disable specific notification types
NOTIFY_ON_APPROVAL="true"
NOTIFY_ON_ERROR="true"
NOTIFY_ON_SUCCESS="true"
NOTIFY_ON_START="false"  # Usually too noisy
NOTIFY_ON_LONG_RUN="true"

# Advanced settings
# Minimum interval between notifications (in seconds) to prevent spam
NOTIFICATION_COOLDOWN=2

# Export all variables for use in the wrapper script
export CODEX_NOTIFY_METHOD CODEX_NOTIFY_SOUND CODEX_NOTIFY_PERSISTENT
export CODEX_NOTIFY_DEBUG CODEX_NOTIFY_DISABLE CODEX_NOTIFY_PATTERNS
export LONG_TASK_THRESHOLD SOUND_SUCCESS SOUND_ERROR SOUND_WARNING
export WINDOWS_APP_ID MAX_LOG_SIZE ROTATE_LOGS
export PRIORITY_APPROVAL PRIORITY_ERROR PRIORITY_SUCCESS PRIORITY_INFO
export TITLE_APPROVAL TITLE_ERROR TITLE_SUCCESS TITLE_INFO TITLE_LONG_RUN
export NOTIFY_ON_APPROVAL NOTIFY_ON_ERROR NOTIFY_ON_SUCCESS NOTIFY_ON_START NOTIFY_ON_LONG_RUN
export NOTIFICATION_COOLDOWN