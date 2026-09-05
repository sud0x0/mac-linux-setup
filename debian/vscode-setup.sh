#!/bin/bash

# ===========================================
# VS Code Setup Automation Script
# Run after ./initial-setup.sh
# Don't execute as root
# ===========================================

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "Error: This script must not be run as root."
    echo "Please run without sudo: ./vscode-setup.sh"
    exit 1
fi

if ! command -v code >/dev/null 2>&1; then
    echo "Error: code not found in PATH. Run ./initial-setup.sh first."
    exit 1
fi

# 1. Remove all extensions first
echo "Removing all existing extensions..."
code --list-extensions | while read extension; do
    code --uninstall-extension "$extension" --force
done

# 2. Install desired extensions
echo "Installing extensions..."
extensions=(
    "github.github-vscode-theme"
    "ms-python.debugpy"
    "ms-python.python"
    "ms-python.vscode-python-envs"
    "ms-vscode-remote.remote-ssh"
)

for ext in "${extensions[@]}"; do
    echo "Installing $ext..."
    code --install-extension "$ext"
done

# 3. Paths
echo "Applying settings..."
SETTINGS_PATH="$HOME/.config/Code/User/settings.json"
KEYBINDINGS_PATH="$HOME/.config/Code/User/keybindings.json"

mkdir -p "$(dirname "$SETTINGS_PATH")"

# 4. Write settings
cat > "$SETTINGS_PATH" << 'EOF'
{
    "terminal.integrated.defaultProfile.linux": "zsh",
    "extensions.ignoreRecommendations": true,
    "editor.wordWrap": "on",
    "editor.fontSize": 18,
    "editor.lineHeight": 1.6,
    "workbench.colorTheme": "GitHub Dark Dimmed",
    "terminal.integrated.fontSize": 16,
    "editor.tabSize": 4,
    "editor.renderWhitespace": "all",
    "editor.formatOnSave": true,
    "editor.fontFamily": "Fira Code",
    "editor.fontLigatures": true,
    "redhat.telemetry.enabled": false,
    "react-native-tools.showUserTips": false,
    "git.openRepositoryInParentFolders": "never",
    "telemetry.telemetryLevel": "off",
    "window.newWindowProfile": "Default"
}
EOF

# 5. Write keybindings
# ctrl+alt+l rather than ctrl+l: ctrl+l is clear-screen in the terminal.
cat > "$KEYBINDINGS_PATH" << 'EOF'
[
    {
        "key": "ctrl+alt+l",
        "command": "workbench.action.focusSideBar",
        "when": "terminalFocus"
    },
    {
        "key": "ctrl+alt+l",
        "command": "workbench.action.terminal.focus",
        "when": "editorFocus"
    },
    {
        "key": "ctrl+alt+l",
        "command": "workbench.action.focusActiveEditorGroup",
        "when": "sideBarFocus"
    }
]
EOF

echo "Done! VS Code has been configured."
echo "You may need to restart VS Code for all changes to take effect."
