#!/bin/zsh

# ===========================================
# MacOS Development Environment Setup Script
# Don't execute as root
# ===========================================

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "Error: This script must not be run as root."
    echo "Please run without sudo: ./setup-mac.sh"
    exit 1
fi

set -e  # Exit on any error

echo "Starting macOS setup..."

# ===========================================
# 1. Install Homebrew
# ===========================================
echo "Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Exported for the rest of this script only; zshrc-template.sh persists this.
    export PATH=/opt/homebrew/bin:$PATH
else
    echo "Homebrew already installed, skipping..."
fi

# ===========================================
# 2. Install Software via Homebrew
# ===========================================
echo "Installing packages..."

brew update

# CLI tools
cli_packages=(
	git
    eza
    zsh-syntax-highlighting
    zsh-autosuggestions
)

# Cask applications
cask_packages=(
	visual-studio-code
    brave-browser
    coteditor
    keka
    rectangle
    font-fira-code
)

# Install CLI packages
for package in "${cli_packages[@]}"; do
    echo "Installing $package..."
    brew install "$package" || echo "Failed to install $package, continuing..."
done

# Install Cask applications
for cask in "${cask_packages[@]}"; do
    echo "Installing $cask..."
    brew install --cask "$cask" || echo "Failed to install $cask, continuing..."
done

# Pin the software that does not need to be regularly updated.
brew pin eza
brew pin zsh-syntax-highlighting
brew pin zsh-autosuggestions
brew cleanup

# ===========================================
# 3. macOS Defaults
# ===========================================
echo "Configuring macOS defaults..."

defaults write com.apple.desktopservices DSDontWriteNetworkStores true
defaults write com.apple.desktopservices DSDontWriteUSBStores true

# ===========================================
# 4. Terminal Configuration
# ===========================================
echo "Configuring terminal..."

profile_name="Clear Dark"
profile_file="$(cd "$(dirname "$0")" && pwd)/Clear Dark.terminal"

open "$profile_file"
sleep 1
osascript <<EOF
tell application "Terminal"
    set default settings to settings set "$profile_name"
    set startup settings to settings set "$profile_name"
end tell
EOF

# ===========================================
# Done!
# ===========================================
echo ""
echo "Setup complete!"
echo "Manually install: Parallels & Parallels RDS Client"
echo ""
