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
    
    # Add Homebrew to PATH
    echo 'export PATH=/opt/homebrew/bin:$PATH' >> ~/.zshrc
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
    kitty
	visual-studio-code
    brave-browser
    google-chrome
    royal-tsx
    balenaetcher
    coteditor
    keka
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
# 4. Kitty Terminal Configuration
# ===========================================
echo "Configuring Kitty terminal..."

KITTY_CONFIG_DIR="$HOME/.config/kitty"
mkdir -p "$KITTY_CONFIG_DIR"

cat > "$KITTY_CONFIG_DIR/kitty.conf" << 'EOF'
# Include other confs
include other.conf
globinclude kitty.d/**/*.conf
envinclude KITTY_CONF_*

# Shell
shell /bin/zsh

# Font
font_family Fira Code
font_size 16.0
adjust_line_height 5

# Scroll
scrollback_lines 200000

# URL
detect_urls yes

# TERM
term xterm-kitty

# Jump to beginning and end of word
map alt+left send_text all \x1b\x62
map alt+right send_text all \x1b\x66

# Jump to beginning and end of line
map cmd+left send_text all \x01
map cmd+right send_text all \x05
EOF

touch "$KITTY_CONFIG_DIR/other.conf"
mkdir -p "$KITTY_CONFIG_DIR/kitty.d"

# ===========================================
# Done!
# ===========================================
echo ""
echo "Setup complete!"
echo ""
