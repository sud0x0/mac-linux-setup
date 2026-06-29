#!/usr/bin/env bash
# Install Claude Code plugins for Go, TypeScript, Python and security.
# Plugins come from the official Anthropic marketplace (claude-plugins-official).

set -euo pipefail

if ! command -v claude >/dev/null 2>&1; then
    echo "Error: claude not found in PATH. Install Claude Code first." >&2
    exit 1
fi

PLUGINS=(
    "gopls-lsp"
    "typescript-lsp"
    "pyright-lsp"
    "security-guidance"
    "code-review"
)

for plugin in "${PLUGINS[@]}"; do
    echo "Installing ${plugin}..."
    claude plugin install "${plugin}@claude-plugins-official"
done

# LSP plugins need these binaries on PATH. Warn if missing.
declare -A BINARIES=(
    ["gopls"]="go install golang.org/x/tools/gopls@latest"
    ["typescript-language-server"]="npm install -g typescript-language-server typescript"
    ["pyright-langserver"]="npm install -g pyright"
)

for bin in "${!BINARIES[@]}"; do
    if ! command -v "${bin}" >/dev/null 2>&1; then
        echo "Warning: ${bin} not found. Install it with: ${BINARIES[$bin]}" >&2
    fi
done

echo "Done!"
