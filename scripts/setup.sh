#!/usr/bin/env bash
# Setup script for Codex WSL notification system
# This script checks dependencies and configures the environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Main setup function
main() {
    print_header "Codex WSL Notification System Setup"

    # Check if running in WSL
    if ! grep -qi microsoft /proc/version; then
        print_error "This script must be run in WSL (Windows Subsystem for Linux)"
        exit 1
    fi
    print_success "Running in WSL environment"

    # Check for Codex
    if ! command -v codex &> /dev/null; then
        print_error "Codex is not installed or not in PATH"
        echo "Please install Codex first: https://github.com/openai/codex"
        exit 1
    fi
    print_success "Codex found at: $(which codex)"

    # Check for PowerShell access
    if ! command -v powershell.exe &> /dev/null; then
        print_error "PowerShell.exe not accessible from WSL"
        exit 1
    fi
    print_success "PowerShell accessible from WSL"

    print_header "Checking Windows Notification Methods"

    # Check for BurntToast
    BURNTTOAST_AVAILABLE=false
    if powershell.exe -NoProfile -Command "Get-Module -ListAvailable -Name BurntToast" 2>/dev/null | grep -q "BurntToast"; then
        print_success "BurntToast PowerShell module is installed"
        BURNTTOAST_AVAILABLE=true
    else
        print_warning "BurntToast not installed"
        echo -e "  To install BurntToast, run this in PowerShell (Admin):"
        echo -e "  ${CYAN}Install-Module -Name BurntToast -Force${NC}"
    fi

    # Check for SnoreToast
    SNORETOAST_AVAILABLE=false
    if [[ -f "/mnt/c/Windows/System32/snoretoast.exe" ]]; then
        print_success "SnoreToast found in System32"
        SNORETOAST_AVAILABLE=true
    elif command -v snoretoast.exe &> /dev/null; then
        print_success "SnoreToast found in PATH"
        SNORETOAST_AVAILABLE=true
    else
        print_warning "SnoreToast not installed"
        echo -e "  Download from: https://github.com/KDE/snoretoast/releases"
        echo -e "  Place snoretoast.exe in C:\\Windows\\System32"
    fi

    # Check for msg.exe fallback
    if command -v msg.exe &> /dev/null; then
        print_success "msg.exe available as fallback"
    else
        print_warning "msg.exe not available"
    fi

    if [[ "$BURNTTOAST_AVAILABLE" == "false" ]] && [[ "$SNORETOAST_AVAILABLE" == "false" ]]; then
        print_warning "No Windows notification tools found. Only terminal bell will be available."
        echo -e "  It's recommended to install at least one notification tool."
    fi

    print_header "Checking Linux Sound System"

    # Check for PulseAudio
    if command -v paplay &> /dev/null; then
        print_success "PulseAudio (paplay) is available"
    elif command -v aplay &> /dev/null; then
        print_success "ALSA (aplay) is available"
    else
        print_warning "No Linux sound system found (notifications will be silent)"
    fi

    # Check for system sounds
    if [[ -d "/usr/share/sounds/freedesktop/stereo" ]]; then
        print_success "System sounds found"
    else
        print_warning "System sounds not found at /usr/share/sounds/freedesktop/stereo"
    fi

    print_header "Setting Up Codex Notification System"

    # Create necessary directories
    mkdir -p ~/bin
    mkdir -p ~/.codex

    # Check if wrapper script exists
    if [[ -f ~/bin/codex-notify ]]; then
        print_success "Wrapper script already exists"
    else
        print_error "Wrapper script not found at ~/bin/codex-notify"
        exit 1
    fi

    # Check if config exists
    if [[ -f ~/.codex/notify-config.sh ]]; then
        print_success "Configuration file exists"
    else
        print_warning "Configuration file not found, using defaults"
    fi

    # Create notification log file
    touch ~/.codex/notifications.log
    print_success "Notification log file created"

    print_header "Configuring Shell Aliases"

    # Detect shell
    SHELL_RC=""
    if [[ "$SHELL" == *"bash"* ]]; then
        SHELL_RC="$HOME/.bashrc"
    elif [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_RC="$HOME/.zshrc"
    else
        print_warning "Unknown shell: $SHELL"
        echo "  Please manually add aliases to your shell configuration"
    fi

    if [[ -n "$SHELL_RC" ]]; then
        # Check if aliases already exist
        if grep -q "alias codex=" "$SHELL_RC" 2>/dev/null; then
            print_info "Codex alias already exists in $SHELL_RC"
            echo -e "  Current alias: ${CYAN}$(grep "alias codex=" "$SHELL_RC")${NC}"
            read -p "  Replace with notification wrapper? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Remove old alias
                sed -i '/alias codex=/d' "$SHELL_RC"
                sed -i '/alias codex-real=/d' "$SHELL_RC"
                sed -i '/alias codex-silent=/d' "$SHELL_RC"
            else
                print_info "Keeping existing alias"
                SHELL_RC=""
            fi
        fi

        if [[ -n "$SHELL_RC" ]]; then
            # Add aliases
            cat >> "$SHELL_RC" << 'EOF'

# Codex notification wrapper aliases
alias codex="~/bin/codex-notify"
alias codex-real="$(which codex)"
alias codex-silent="CODEX_NOTIFY_DISABLE=1 codex"
EOF
            print_success "Aliases added to $SHELL_RC"
            echo -e "  ${CYAN}codex${NC}        - Run with notifications"
            echo -e "  ${CYAN}codex-real${NC}   - Run original Codex without wrapper"
            echo -e "  ${CYAN}codex-silent${NC} - Run with notifications disabled"
        fi
    fi

    print_header "Testing Notification System"

    echo "Testing different notification types..."
    echo ""

    # Test notifications
    ~/bin/codex-notify test all

    print_header "Setup Complete!"

    echo -e "The Codex notification system is now configured.\n"
    echo -e "Next steps:"
    echo -e "1. ${CYAN}source $SHELL_RC${NC} to load the new aliases"
    echo -e "2. Edit ${CYAN}~/.codex/notify-config.sh${NC} to customize settings"
    echo -e "3. Run ${CYAN}codex${NC} to use Codex with notifications"
    echo -e ""
    echo -e "Test commands:"
    echo -e "  ${CYAN}codex-notify test approval${NC}  - Test approval notification"
    echo -e "  ${CYAN}codex-notify test complete${NC}  - Test completion notification"
    echo -e "  ${CYAN}codex-notify test error${NC}     - Test error notification"
    echo -e "  ${CYAN}codex-notify test all${NC}       - Test all notification types"
    echo -e ""
    echo -e "View notification log:"
    echo -e "  ${CYAN}tail -f ~/.codex/notifications.log${NC}"

    if [[ "$BURNTTOAST_AVAILABLE" == "false" ]] && [[ "$SNORETOAST_AVAILABLE" == "false" ]]; then
        echo -e ""
        print_warning "Recommendation: Install BurntToast or SnoreToast for rich Windows notifications"
    fi
}

# Run main function
main "$@"