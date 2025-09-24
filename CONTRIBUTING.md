# Contributing to Codex Notify WSL

Thank you for your interest in contributing to Codex Notify WSL. This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our code of conduct: be respectful, constructive, and professional.

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

1. Your environment (Windows version, WSL version, Codex version)
2. Steps to reproduce the issue
3. Expected behavior
4. Actual behavior
5. Relevant log output from `~/.codex/notifications.log`

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When suggesting an enhancement, include:

1. Use case for the feature
2. Expected behavior
3. Possible implementation approach
4. Any potential drawbacks

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly in WSL environment
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Development Setup

### Prerequisites

- WSL 2 on Windows 10/11
- Node.js 14+
- Codex CLI installed
- BurntToast or SnoreToast (for testing)

### Local Development

1. Clone the repository:
   ```bash
   git clone https://github.com/nomad5/codex-notify-wsl.git
   cd codex-notify-wsl
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Link for local testing:
   ```bash
   npm link
   ```

4. Test notifications:
   ```bash
   codex-notify test all
   ```

## Testing

### Manual Testing

Test all notification types:
```bash
codex-notify test approval
codex-notify test success
codex-notify test error
codex-notify test all
```

### Testing Checklist

- [ ] Test with BurntToast
- [ ] Test with SnoreToast
- [ ] Test fallback to msg.exe
- [ ] Test fallback to terminal bell
- [ ] Test configuration loading
- [ ] Test environment variable overrides
- [ ] Test long-running task detection
- [ ] Test log rotation
- [ ] Test with actual Codex commands

## Code Style

### Bash Scripts

- Use bash strict mode where appropriate
- Quote variables to prevent word splitting
- Use `[[ ]]` for conditionals
- Add comments for complex logic
- Follow Google Shell Style Guide

### JavaScript

- Use ES6+ features
- Handle errors gracefully
- Add JSDoc comments for functions
- Keep it simple and readable

### Python

- Follow PEP 8
- Use type hints where helpful
- Handle exceptions gracefully
- Keep it minimal

## Documentation

- Update README.md for user-facing changes
- Update CHANGELOG.md following Keep a Changelog format
- Add inline comments for complex code
- Update configuration examples

## Release Process

1. Update version in package.json
2. Update CHANGELOG.md
3. Create git tag: `git tag v1.0.0`
4. Push tags: `git push --tags`
5. Publish to npm: `npm publish`
6. Create GitHub release

## Questions?

Feel free to open an issue for any questions about contributing.