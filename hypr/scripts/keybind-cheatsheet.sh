#!/usr/bin/env bash
# ============================================================
#  keybind-cheatsheet.sh
#  ~/.config/hypr/scripts/keybind-cheatsheet.sh
#  Shows all hyprland keybinds in rofi dmenu
#  Trigger: Super+/
# ============================================================

CONF="$HOME/.config/hypr/hyprland.conf"
CLIP_THEME="$HOME/.config/rofi/themes/clipboard.rasi"

# Parse all bind lines from hyprland.conf
binds=$(grep -E '^\s*bind[dre]*\s*=' "$CONF" | \
  sed 's/^\s*bind[dre]*\s*[rl]*\s*=\s*//' | \
  awk -F',' '{
    mod=$1; key=$2; act=$3; desc=$4
    gsub(/^ +| +$/, "", mod)
    gsub(/^ +| +$/, "", key)
    gsub(/^ +| +$/, "", act)
    gsub(/^ +| +$/, "", desc)
    gsub(/\$mainMod/, "SUPER", mod)
    gsub(/\$mainMod/, "SUPER", key)
    # Use description if available (bindd format), otherwise use action
    label = (desc != "") ? desc : act
    # Clean up exec prefix
    gsub(/exec, /, "", label)
    gsub(/~\/\.config\/hypr\/scripts\//, "", label)
    printf "%-30s  %s + %s\n", label, mod, key
  }' | sort)

# Toggle — if rofi is open close it
pkill rofi && exit 0

echo "$binds" | rofi -dmenu \
    -theme "$CLIP_THEME" \
    -theme-str '* { font: "Maple Mono NF 13"; }' \
    -theme-str 'window { width: 900px; }' \
    -theme-str '#inputbar { background-color: @main-br; }' \
    -p "  Keybinds" \
    -no-custom \
    -i
