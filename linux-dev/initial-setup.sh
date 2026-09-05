#!/bin/bash

# ===========================================
# Ubuntu Development Environment Setup Script
# Don't execute as root
# Supports arm64 and amd64
# ===========================================

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "Error: This script must not be run as root."
    echo "Please run without sudo: ./setup-ubuntu.sh"
    exit 1
fi

set -e

echo "Starting Ubuntu setup..."

# ===========================================
# Architecture Detection
# Go and gitleaks both ship per-arch binaries
# but name them differently: go uses amd64,
# gitleaks uses x64.
# ===========================================
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
    amd64)
        GO_ARCH="amd64"
        GITLEAKS_ARCH="x64"
        ;;
    arm64)
        GO_ARCH="arm64"
        GITLEAKS_ARCH="arm64"
        ;;
    *)
        echo "Error: unsupported architecture '$ARCH'."
        echo "This script supports amd64 and arm64 only."
        exit 1
        ;;
esac
echo "Detected architecture: $ARCH"

# ===========================================
# 1. System Update
# ===========================================
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# ===========================================
# 2. Base Dependencies
# ===========================================
echo "Installing base dependencies..."
sudo apt install -y \
    curl \
    wget \
    git \
    vim-gtk3 \
    notepadqq \
    terminator \
    byobu \
    fonts-firacode \
    build-essential \
    pkg-config \
    libssl-dev \
    unzip \
    zip \
    jq \
    ripgrep \
    zsh \
    pipx \
    python3 \
    python3-pip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# ===========================================
# 3. SSH Server
# ===========================================
echo "Installing and enabling SSH server..."
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
echo "SSH server is running."
echo "VM IP address:"
ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1

# ===========================================
# 4. Set zsh as default shell
# ===========================================
echo "Setting zsh as default shell..."
chsh -s $(which zsh)

# ===========================================
# 5. Podman
# ===========================================
echo "Installing Podman..."
sudo apt install -y podman

echo "Configuring rootless Podman..."
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER

# ===========================================
# 6. Podman Compose
# ===========================================
echo "Installing podman-compose..."
pipx install podman-compose
pipx ensurepath

# ===========================================
# 7. Go
# ===========================================
echo "Installing Go..."
GO_VERSION=$(curl -s https://go.dev/dl/?mode=json | jq -r '.[0].version')
wget -O /tmp/go.tar.gz "https://go.dev/dl/${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz

# Exported for the rest of this script only; zshrc-template.sh persists these.
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# ===========================================
# 8. Rust
# ===========================================
echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# ===========================================
# 9. Node and pnpm
# ===========================================
echo "Installing Node..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

echo "Installing pnpm..."
curl -fsSL https://get.pnpm.io/install.sh | sh -
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# ===========================================
# 10. Ansible and ansible-lint
# ===========================================
echo "Installing Ansible..."
pipx install --include-deps ansible
pipx install ansible-lint
pipx ensurepath

# ===========================================
# 11. Terraform and Packer
# ===========================================
echo "Installing Terraform and Packer..."
wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install -y terraform packer xorriso

# ===========================================
# 12. pre-commit
# ===========================================
echo "Installing pre-commit..."
pipx install pre-commit

# ===========================================
# 13. gitleaks
# ===========================================
echo "Installing gitleaks..."
GITLEAKS_VERSION=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | jq -r '.tag_name')
wget -O /tmp/gitleaks.tar.gz "https://github.com/gitleaks/gitleaks/releases/download/${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION#v}_linux_${GITLEAKS_ARCH}.tar.gz"
sudo tar -C /usr/local/bin -xzf /tmp/gitleaks.tar.gz gitleaks
rm /tmp/gitleaks.tar.gz

# ===========================================
# 14. semgrep
# ===========================================
echo "Installing semgrep..."
pipx install semgrep

# ===========================================
# 15. Go tools
# ===========================================
echo "Installing Go tools..."

go_tools=(
    "golang.org/x/tools/gopls@latest"
    "github.com/cweill/gotests/gotests@latest"
    "golang.org/x/vuln/cmd/govulncheck@latest"
    "honnef.co/go/tools/cmd/staticcheck@latest"
    "github.com/pressly/goose/v3/cmd/goose@latest"
    "github.com/go-delve/delve/cmd/dlv@latest"
    "github.com/fatih/gomodifytags@latest"
    "github.com/josharian/impl@latest"
    "github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest"
    "github.com/air-verse/air@latest"
)

for tool in "${go_tools[@]}"; do
    echo "Installing $tool..."
    go install "$tool" || echo "Failed to install $tool, continuing..."
done

go telemetry off
echo "Go tools installed."

# ===========================================
# 16. TypeScript and Svelte tools
# ===========================================
echo "Installing TypeScript and Svelte tools..."

ts_tools=(
    "typescript"
    "svelte-language-server"
    "svelte-check"
    "socket"
    "eslint"
    "@eslint/js"
    "@typescript-eslint/eslint-plugin"
    "@typescript-eslint/parser"
    "eslint-plugin-svelte"
    "svelte-eslint-parser"
    "globals"
    "prettier"
    "prettier-plugin-svelte"
)

for tool in "${ts_tools[@]}"; do
    echo "Installing $tool..."
    pnpm add -g "$tool" || echo "Failed to install $tool, continuing..."
done

echo "TypeScript and Svelte tools installed."

# ===========================================
# 17. Python tools
# ===========================================
echo "Installing Python tools..."
pip3 install requests --break-system-packages
echo "Python tools installed."

# ===========================================
# 18. C tools
# ===========================================
echo "Installing C tools..."
sudo apt install -y \
    gcc \
    gdb \
    clang \
    clangd \
    clang-format \
    clang-tidy \
    cmake \
    valgrind \
    lldb
echo "C tools installed."

# ===========================================
# 19. eza
# ===========================================
echo "Installing eza..."
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
    sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
    sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update && sudo apt install -y eza

# ===========================================
# 20. zsh plugins
# ===========================================
echo "Installing zsh plugins..."
sudo apt install -y zsh-syntax-highlighting zsh-autosuggestions

# ===========================================
# 21. Disable automatic update notifications
# ===========================================
echo "Disabling automatic update notifications..."
sudo apt remove -y update-notifier update-notifier-common
sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null << 'EOF'
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF
echo "Automatic update notifications disabled."

# ===========================================
# 22. goreleaser
# ===========================================
echo "Installing goreleaser..."
go install github.com/goreleaser/goreleaser/v2@latest

# ===========================================
# 23. syft
# ===========================================
echo "Installing syft..."
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | \
    sh -s -- -b "$HOME/.local/bin"

# ===========================================
# 24. Claude Code
# ===========================================
echo "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash
echo "Claude Code installed. Run 'claude' to start and authenticate."

# ===========================================
# Done!
# ===========================================
echo ""
echo "Setup complete!"
echo ""
echo "Important next steps:"
echo "  1. Log out and back in for zsh to become the default shell"
echo "  2. Run source ~/.zshrc to reload shell configuration"
echo "  3. Apply the Terminator config: ./setup-terminator.sh"
echo "  4. Authenticate Claude Code ('claude'), then run ./setup-claude-plugins.sh"
echo "  5. Connect via VS Code Remote SSH and run the vscode-server extension installer"
echo "  6. Clone your repositories and run make setup in each"
echo ""
echo "SSH server is running. Connect from macOS using:"
echo "  ssh $(whoami)@<VM_IP>"
echo "VM IP address:"
ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1
echo ""
