#!/bin/bash

# ===========================================
# Debian Laptop Setup Script
# Minimal host: browser, editor, terminal.
# Development happens inside VMs.
# Don't execute as root
# ===========================================

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "Error: This script must not be run as root."
    echo "Please run without sudo: ./initial-setup.sh"
    exit 1
fi

set -e

echo "Starting Debian setup..."

# ===========================================
# 1. System Update
# ===========================================
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# ===========================================
# 2. Base Packages
# ===========================================
echo "Installing base packages..."
sudo apt install -y \
    curl \
    wget \
    netcat-openbsd \
    nmap \
    git \
    build-essential \
    vim-gtk3 \
    terminator \
    byobu \
    fonts-firacode \
    python3 \
    python3-pip \
    zsh \
    zsh-syntax-highlighting \
    zsh-autosuggestions \
    apt-transport-https \
    ca-certificates \
    gnupg

sudo mkdir -p /etc/apt/keyrings

# ===========================================
# 3. Kernel Headers
# Needed to build the VMware Workstation
# kernel modules (vmmon/vmnet).
# ===========================================
echo "Installing kernel headers..."
if ! sudo apt install -y "linux-headers-$(uname -r)"; then
    echo "No headers for the running kernel ($(uname -r)) - likely a pending kernel upgrade."
    echo "Installing the headers metapackage instead; reboot before building VMware modules."
    sudo apt install -y "linux-headers-$(dpkg --print-architecture)"
fi

# ===========================================
# 4. Set zsh as default shell
# ===========================================
echo "Setting zsh as default shell..."
chsh -s "$(which zsh)"

# ===========================================
# 5. VS Code
# ===========================================
echo "Installing VS Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null
sudo chmod 644 /etc/apt/keyrings/packages.microsoft.gpg

echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
    https://packages.microsoft.com/repos/code stable main" | \
    sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

sudo apt update && sudo apt install -y code

# ===========================================
# 6. Brave Browser
# ===========================================
echo "Installing Brave..."
curl -fsS https://dl.brave.com/install.sh | sh

# ===========================================
# 7. eza
# ===========================================
echo "Installing eza..."
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
    sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
    sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update && sudo apt install -y eza

# ===========================================
# Done!
# ===========================================
echo ""
echo "Setup complete!"
echo ""
echo "Important next steps:"
echo "  1. Log out and back in for zsh to become the default shell"
echo "  2. cp zshrc-template.sh ~/.zshrc && source ~/.zshrc"
echo "  3. Apply the Terminator config: ./setup-terminator.sh"
echo "  4. Configure VS Code: ./vscode-setup.sh"
echo ""
echo "Manually install: VMware Workstation Pro & Parallels RDS Client"
echo ""
