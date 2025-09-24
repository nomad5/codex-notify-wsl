# Codex Notify for WSL

[![npm version](https://img.shields.io/npm/v/codex-notify-wsl.svg)](https://www.npmjs.com/package/codex-notify-wsl)
[![npm downloads](https://img.shields.io/npm/dm/codex-notify-wsl.svg)](https://www.npmjs.com/package/codex-notify-wsl)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node version](https://img.shields.io/node/v/codex-notify-wsl.svg)](https://nodejs.org)
[![GitHub stars](https://img.shields.io/github/stars/nomad5/codex-notify-wsl.svg?style=social)](https://github.com/nomad5/codex-notify-wsl)
[![GitHub issues](https://img.shields.io/github/issues/nomad5/codex-notify-wsl.svg)](https://github.com/nomad5/codex-notify-wsl/issues)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/nomad5/codex-notify-wsl/pulls)
[![WSL 2](https://img.shields.io/badge/WSL-2-blue.svg)](https://docs.microsoft.com/en-us/windows/wsl/)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11-blue.svg)](https://www.microsoft.com/windows)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/nomad5/codex-notify-wsl/graphs/commit-activity)

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