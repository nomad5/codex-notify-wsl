#!/usr/bin/env bash
# Codex Notify Installer

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
BIN_SOURCE="$SCRIPT_DIR/bin/codex-notify"
TEMPLATE_SOURCE="$SCRIPT_DIR/config/.env.example"
NOTIFY_PY_SOURCE="$SCRIPT_DIR/lib/notify.py"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Codex Notify for WSL - Installer"
echo "================================"
echo ""

# Check WSL
if ! grep -qi microsoft /proc/version; then
    echo -e "${RED}Error: This must be run in WSL${NC}"
    exit 1
fi

# Check Codex
if ! command -v codex &> /dev/null; then
    echo -e "${RED}Error: Codex not found. Install Codex first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Codex found"

# Check PowerShell
if ! command -v powershell.exe &> /dev/null; then
    echo -e "${RED}Error: PowerShell not accessible from WSL${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} PowerShell accessible"

# Check notification tools
echo ""
echo "Checking Windows notification tools..."

BURNTTOAST=false
if powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-Module -ListAvailable -Name BurntToast" 2>/dev/null | grep -q "BurntToast"; then
    echo -e "${GREEN}✓${NC} BurntToast installed"
    BURNTTOAST=true
else
    echo -e "${YELLOW}!${NC} BurntToast not installed (recommended)"
    echo "  Install with: Install-Module -Name BurntToast -Force"
fi

SNORETOAST=false
if [[ -f "/mnt/c/Windows/System32/snoretoast.exe" ]]; then
    echo -e "${GREEN}✓${NC} SnoreToast installed"
    SNORETOAST=true
else
    echo -e "${YELLOW}!${NC} SnoreToast not installed"
fi

if ! $BURNTTOAST && ! $SNORETOAST; then
    echo ""
    echo -e "${YELLOW}Warning: No notification tools found${NC}"
    echo "Install BurntToast or SnoreToast for best experience"
    echo "Continue with basic notifications? [y/N]"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install files
echo ""
echo "Installing files..."

# Create directories
mkdir -p ~/bin
mkdir -p ~/.codex

# Copy main script
cp "$BIN_SOURCE" ~/bin/
chmod +x ~/bin/codex-notify
echo -e "${GREEN}✓${NC} Installed codex-notify to ~/bin/"

# Copy config if it doesn't exist
if [[ ! -f ~/.codex/notify.env ]]; then
    if [[ -f "$TEMPLATE_SOURCE" ]]; then
        cp "$TEMPLATE_SOURCE" ~/.codex/notify.env
        echo -e "${GREEN}✓${NC} Created config file ~/.codex/notify.env"
    else
        echo -e "${YELLOW}!${NC} Configuration template missing at $TEMPLATE_SOURCE"
        exit 1
    fi
else
    echo -e "${YELLOW}!${NC} Config already exists, keeping your settings"
fi

# Copy notify.py for Linux sounds
if [[ -f "$NOTIFY_PY_SOURCE" ]]; then
    cp "$NOTIFY_PY_SOURCE" ~/.codex/
    chmod +x ~/.codex/notify.py
    echo -e "${GREEN}✓${NC} Installed Linux sound support"
else
    echo -e "${YELLOW}!${NC} notify.py not found; skipping sound support"
fi

# Setup aliases
echo ""
echo "Setting up aliases..."

SHELL_RC=""
if [[ "$SHELL" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
elif [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

if [[ -n "$SHELL_RC" ]]; then
    # Remove old aliases if they exist
    sed -i '/alias codex=/d' "$SHELL_RC" 2>/dev/null || true
    sed -i '/alias codex-real=/d' "$SHELL_RC" 2>/dev/null || true
    sed -i '/alias codex-silent=/d' "$SHELL_RC" 2>/dev/null || true

    # Add new aliases
    cat >> "$SHELL_RC" << 'EOF'

# Codex Notify
alias codex="~/bin/codex-notify"
alias codex-real="$(which codex)"
alias codex-silent="CODEX_NOTIFY_ENABLED=false codex"
EOF

    echo -e "${GREEN}✓${NC} Added aliases to $SHELL_RC"
else
    echo -e "${YELLOW}!${NC} Unknown shell. Add these aliases manually:"
    echo '  alias codex="~/bin/codex-notify"'
    echo '  alias codex-real="$(which codex)"'
    echo '  alias codex-silent="CODEX_NOTIFY_ENABLED=false codex"'
fi

# Setup Codex hook for completion sounds
echo ""
echo "Setting up Codex hooks..."

# Check if Codex config exists
CODEX_CONFIG="$HOME/.codex/config.toml"
if [[ -f "$CODEX_CONFIG" ]]; then
    # Check if notify hook already exists
    if ! grep -q "^notify = " "$CODEX_CONFIG"; then
        # Add notify hook
        sed -i '1a\notify = ["python3", "'$HOME'/.codex/notify.py"]' "$CODEX_CONFIG"
        echo -e "${GREEN}✓${NC} Added Codex notify hook"
    else
        echo -e "${YELLOW}!${NC} Codex notify hook already configured"
    fi
else
    echo -e "${YELLOW}!${NC} Codex config not found. Add this to ~/.codex/config.toml:"
    echo '  notify = ["python3", "'$HOME'/.codex/notify.py"]'
fi

# Test
echo ""
echo "Testing notifications..."
~/bin/codex-notify test approval

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Reload your shell: source $SHELL_RC"
echo "2. Edit config: codex-notify config"
echo "3. Test: codex-notify test all"
echo "4. Use: codex 'your prompt'"
echo ""

if ! $BURNTTOAST; then
    echo "Recommended: Install BurntToast for rich notifications"
    echo "  PowerShell Admin: Install-Module -Name BurntToast -Force"
fi
