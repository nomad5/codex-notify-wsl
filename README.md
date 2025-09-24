# Codex Notify for WSL

Windows toast notifications for Codex running in WSL. Never miss an approval prompt again.

## Features

- Windows toast notifications when Codex needs approval
- Configurable notification types (approval, success, error, long-running)
- Multiple notification methods with automatic fallback
- Simple configuration file
- Minimal dependencies

## Installation

### npm (Recommended)

```bash
npm install -g codex-notify-wsl
```

### Manual Installation

```bash
git clone https://github.com/yourusername/codex-notify-wsl.git
cd codex-notify-wsl
npm install
npm link
```

## Quick Setup

1. Install a Windows notification tool (choose one):

   **BurntToast** (Recommended):
   ```powershell
   # PowerShell Admin
   Install-Module -Name BurntToast -Force
   ```

   **SnoreToast**:
   Download from [GitHub](https://github.com/KDE/snoretoast/releases) and place in `C:\Windows\System32`

2. Reload your shell:
   ```bash
   source ~/.bashrc
   ```

3. Test notifications:
   ```bash
   codex-notify test all
   ```

## Usage

```bash
# Use Codex with notifications
codex "your prompt"

# Without notifications
codex-silent "your prompt"

# Direct Codex (bypass wrapper)
codex-real "your prompt"
```

## Configuration

Configuration file: `~/.codex/notify.env`

```bash
# Edit configuration
codex-notify config

# Or edit directly
nano ~/.codex/notify.env
```

### Configuration Options

```bash
# Core Settings
NOTIFY_ENABLED=true          # Enable/disable all notifications
NOTIFY_METHOD=auto          # auto, burnttoast, snoretoast, msg, bell
NOTIFY_SOUNDS=true          # Play sounds
NOTIFY_PERSISTENT=false     # Keep notifications until dismissed
NOTIFY_DEBUG=false          # Verbose logging

# Event Triggers
NOTIFY_ON_APPROVAL=true     # Approval prompts
NOTIFY_ON_SUCCESS=true      # Task completion
NOTIFY_ON_ERROR=true        # Errors
NOTIFY_ON_LONG_RUN=true     # Long-running tasks (>60s)

# Customization
LONG_TASK_THRESHOLD=60      # Seconds before "long-running" alert
CUSTOM_PATTERNS=""          # Pipe-separated custom patterns
USE_EMOJIS=true            # Visual emojis in titles
NOTIFICATION_COOLDOWN=2     # Min seconds between notifications
```

### Environment Variable Overrides

Override any setting via environment variables:

```bash
# Disable for one command
CODEX_NOTIFY_ENABLED=false codex "your prompt"

# Force specific method
CODEX_NOTIFY_METHOD=burnttoast codex "your prompt"

# Debug mode
CODEX_NOTIFY_DEBUG=true codex "your prompt"
```

## Testing

```bash
# Test all notification types
codex-notify test all

# Test specific types
codex-notify test approval
codex-notify test success
codex-notify test error
```

## Troubleshooting

### No notifications appearing

1. Check Windows Focus Assist settings
2. Verify notification tool is installed:
   ```powershell
   Get-Module -ListAvailable -Name BurntToast
   ```
3. Check logs:
   ```bash
   tail ~/.codex/notifications.log
   ```

### Common Issues

| Problem | Solution |
|---------|----------|
| No notifications | Check Focus Assist, install BurntToast/SnoreToast |
| No sound | Check Windows volume mixer |
| Wrong notification type | Adjust patterns in config file |

## How It Works

The wrapper script monitors Codex output for specific patterns:
- "approval requested", "waiting for permission" → Approval notification
- "task complete", "finished successfully" → Success notification
- "error occurred", "failed" → Error notification
- Tasks >60 seconds → Long-running notification

## Requirements

- WSL 2 on Windows 10/11
- Codex CLI
- PowerShell access from WSL
- BurntToast or SnoreToast (optional but recommended)

## Files

```
codex-notify         # Main wrapper script
.env.example        # Configuration template
install.sh          # Installation script
README.md          # This file
```

## Contributing

Pull requests welcome. Please test changes with both BurntToast and fallback methods.

## License

MIT