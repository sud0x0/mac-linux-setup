# mac-linux-setup

A collection of shell scripts to automate development environment setup on macOS, Debian and Ubuntu.

## Usage

**macOS:**

```zsh
cd mac

chmod +x initial-setup.sh
./initial-setup.sh

chmod +x vscode-setup.sh
./vscode-setup.sh

cp zshrc-template.sh ~/.zshrc
```

Then manually install Parallels and the Parallels RDS Client.

**Ubuntu:**

```bash
cd linux-dev

chmod +x initial-setup.sh
./initial-setup.sh

cp zshrc-template.sh ~/.zshrc

# Apply the Terminator theme, font, and keybindings
chmod +x setup-terminator.sh
./setup-terminator.sh

# Install Claude Code plugins (run after Claude Code is authenticated)
chmod +x setup-claude-plugins.sh
./setup-claude-plugins.sh

# once you connect VSCode in the local machine to the VM via SSH, run setup-vscode-server.sh
chmod +x setup-vscode-server.sh
./setup-vscode-server.sh
```

**Debian:**

```bash
cd debian

chmod +x initial-setup.sh
./initial-setup.sh

cp zshrc-template.sh ~/.zshrc

# Apply the Terminator theme, font, and keybindings
chmod +x setup-terminator.sh
./setup-terminator.sh

chmod +x vscode-setup.sh
./vscode-setup.sh
```

Then manually install VMware Workstation Pro and the Parallels RDS Client.

## Development Pattern

- Connect to the development server via SSH and do the development there: https://code.visualstudio.com/docs/remote/ssh
- Repositories will live in the VM and the repository manager.
- Podman will be used to run and build the code.
- Why: This way the main host is minimal and reduces the blast radius of potential supply chain attacks
