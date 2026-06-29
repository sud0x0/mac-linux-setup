#!/bin/bash
# ===========================================
# Terminator Configuration Installer
# Applies theme, font, and keybindings.
# Run after terminator is installed (see os-setup.sh).
# ===========================================

set -e

if ! command -v terminator >/dev/null 2>&1; then
    echo "Error: terminator is not installed. Install it first (see os-setup.sh)."
    exit 1
fi

CONFIG_DIR="$HOME/.config/terminator"
CONFIG_FILE="$CONFIG_DIR/config"

mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG_FILE" ]; then
    BACKUP="$CONFIG_FILE.bak.$(date +%Y%m%d%H%M%S)"
    echo "Existing config found, backing up to $BACKUP"
    cp "$CONFIG_FILE" "$BACKUP"
fi

echo "Writing terminator config to $CONFIG_FILE..."

cat > "$CONFIG_FILE" <<'EOF'
[global_config]
[keybindings]
  cycle_next = <Primary>braceleft
  cycle_prev = <Primary>braceright
  go_next = ""
  go_prev = ""
  go_up = ""
  go_down = ""
  go_left = ""
  go_right = ""
  rotate_cw = ""
  rotate_ccw = ""
  split_auto = ""
  split_horiz = <Primary><Shift>Return
  split_vert = ""
  close_term = ""
  toggle_scrollbar = ""
  search = <Primary><Shift>f
  close_window = ""
  resize_up = ""
  resize_down = ""
  resize_left = ""
  resize_right = ""
  move_tab_right = ""
  move_tab_left = ""
  toggle_zoom = ""
  scaled_zoom = ""
  next_tab = <Primary><Shift>Right
  prev_tab = <Primary><Shift>Left
  full_screen = ""
  reset = ""
  reset_clear = ""
  hide_window = ""
  group_all = ""
  ungroup_all = ""
  ungroup_win = ""
  group_tab = ""
  ungroup_tab = ""
  new_window = ""
  new_terminator = ""
  insert_number = ""
  insert_padded = ""
  edit_window_title = ""
  edit_tab_title = <Primary><Shift><Alt>t
  edit_terminal_title = ""
  layout_launcher = ""
  preferences_keybindings = ""
  help = ""
[profiles]
  [[default]]
    background_color = "#002b36"
    cursor_fg_color = "#000000"
    cursor_bg_color = "#aaaaaa"
    font = Fira Code 14
    foreground_color = "#839496"
    show_titlebar = False
    use_system_font = False
[layouts]
  [[default]]
    [[[window0]]]
      type = Window
      parent = ""
    [[[child1]]]
      type = Terminal
      parent = window0
[plugins]
EOF

echo ""
echo "Done. Restart terminator to apply the new configuration."
