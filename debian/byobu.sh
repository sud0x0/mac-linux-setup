#!/bin/bash
# byobu-statusbar.sh
# Byobu status bar: window tabs on the left, IP, date and time on the right, no colour.
# Run from a plain terminal, not inside byobu.
set -euo pipefail

# Remove any custom status scripts from earlier attempts
rm -f ~/.byobu/bin/[0-9]*_*
rmdir ~/.byobu/bin 2>/dev/null || true

# Remove the customised status file so byobu uses its defaults
rm -f ~/.byobu/status

# Write the tmux config
mkdir -p ~/.byobu
touch ~/.byobu/.tmux.conf
sed -i '/^set -g status-left/d;/^set -g status-right/d;/^set -g status-interval/d;/^set -g status-position/d' ~/.byobu/.tmux.conf

cat >> ~/.byobu/.tmux.conf <<'EOF'
set -g status-position bottom
set -g status-left ""
set -g status-right "#(ip route get 1.1.1.1 2>/dev/null | awk '/src/{print $7; exit}') %Y-%m-%d %H:%M:%S"
set -g status-right-length 60
set -g status-interval 5
EOF

# Restart the byobu server so the config is reloaded
byobu kill-server 2>/dev/null || true

echo "Done. Run: byobu"
echo "F2: New window"
echo "F3 F4: Previous / next window"
echo "F8: Rename window"
echo "Ctrl-D: Close window or pane"
echo ""
echo "Panes"
echo ""
echo "Ctrl-F2: Split vertically"
echo "Shift-F2: Split horizontally"
echo "Shift-F3 Shift-F4: Move focus between panes"