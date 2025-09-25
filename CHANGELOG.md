# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2025-09-25

### Fixed
- Strip ANSI color codes before matching Codex output so approval prompts like "Allow command?" trigger notifications reliably.

## [1.0.2] - 2025-09-25

### Fixed
- Expanded approval detection to include all Codex confirmation prompts ("Allow", "Confirm", etc.) across the wrapper, Python hook, and default config.

## [1.0.1] - 2024-09-24

### Added
- MIT LICENSE file
- CHANGELOG.md for version tracking
- CONTRIBUTING.md with contribution guidelines
- bin/setup.js wrapper for npm compatibility
- GitHub Actions CI/CD workflow
- Cross-platform stat command compatibility
- Input sanitization for PowerShell commands
- Timeout handling for notification commands
- Better error messages and validation

### Fixed
- Broken npm bin reference to setup.js
- Cross-platform compatibility issues with stat command
- PowerShell command escaping for special characters
- Memory leak in long-running monitor process

### Security
- Added input sanitization for notification text
- Escaped special characters in PowerShell commands
- Added command injection prevention

## [1.0.0] - 2024-09-24

### Added
- Initial release
- Windows toast notifications for Codex in WSL
- Support for BurntToast and SnoreToast
- Configurable notification types
- Multiple notification methods with fallback
- Simple configuration file
- Installation script
- Test commands for all notification types
- Logging with rotation
- Custom pattern matching
- Long-running task detection

[1.0.3]: https://github.com/nomad5/codex-notify-wsl/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/nomad5/codex-notify-wsl/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/nomad5/codex-notify-wsl/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/nomad5/codex-notify-wsl/releases/tag/v1.0.0
