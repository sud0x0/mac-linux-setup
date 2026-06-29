#!/bin/bash
# ===========================================
# VS Code Server Extension Installer
# Run this on the Ubuntu VM after first
# connecting via Remote SSH at least once
# ===========================================

set -e

# Wait for VS Code Server to exist
VSCODE_SERVER_BIN=$(ls ~/.vscode-server/cli/servers/Stable-*/server/bin/code-server 2>/dev/null | head -1)

if [ -z "$VSCODE_SERVER_BIN" ]; then
    echo "Error: VS Code Server not found in ~/.vscode-server"
    echo "Please connect to this VM via Remote SSH at least once first, then re-run this script."
    exit 1
fi

echo "Found VS Code Server at: $VSCODE_SERVER_BIN"
echo "Installing extensions..."

extensions=(
    "golang.go"
    "hashicorp.hcl"
    "hashicorp.terraform"
    "llvm-vs-code-extensions.lldb-dap"
    "ms-ossdata.vscode-pgsql"
    "ms-python.debugpy"
    "ms-python.python"
    "ms-python.vscode-python-envs"
    "ms-vscode.cpptools"
    "ms-vscode.vscode-typescript-next"
    "redhat.ansible"
    "redhat.vscode-xml"
    "redhat.vscode-yaml"
    "rust-lang.rust-analyzer"
    "tamasfe.even-better-toml"
    "svelte.svelte-vscode"
    "esbenp.prettier-vscode"
    "dbaeumer.vscode-eslint"
)

for ext in "${extensions[@]}"; do
    echo "Installing $ext..."
    "$VSCODE_SERVER_BIN" --install-extension "$ext" || echo "Failed to install $ext, continuing..."
done

echo ""
echo "Done. Reconnect VS Code to the VM to activate all extensions."
