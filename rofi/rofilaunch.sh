#!/usr/bin/env bash
# ============================================================
#  rofilaunch.sh
#  ~/.config/hypr/scripts/rofilaunch.sh
#
#  Handles all rofi modes:
#    rofilaunch.sh d  — app launcher (drun)
#    rofilaunch.sh w  — window switcher
#    rofilaunch.sh f  — file browser
#    rofilaunch.sh c  — clipboard (cliphist)
#
#  Generates wallpaper thumbnail + blur for sidebar on first
#  run or when wallpaper changes.
# ============================================================

ROFI_CACHE="$HOME/.cache/rofi"
ROFI_THEMES="$HOME/.config/rofi/themes"
ROFI_THEME="$HOME/.config/rofi/themes/style_1.rasi"
CLIP_THEME="$HOME/.config/rofi/themes/clipboard.rasi"
WALL_CACHE="$HOME/.cache/wallpaper-rotate"

mkdir -p "$ROFI_CACHE"

# ── Toggle: if rofi is running, kill it ───────────────────
pkill rofi && exit 0

# ── Font override based on monitor resolution ─────────────
# Larger font on the ultrawide at native 5120x1440
get_font_size() {
    local focused_width
    focused_width=$(hyprctl -j monitors 2>/dev/null \
        | python3 -c "import sys,json; m=[m for m in json.load(sys.stdin) if m['focused']]; print(m[0]['width'] if m else 1920)" 2>/dev/null)
    if [[ "$focused_width" -ge 5000 ]]; then
        echo "14"
    elif [[ "$focused_width" -ge 3000 ]]; then
        echo "13"
    else
        echo "11"
    fi
}

FONT_SIZE=$(get_font_size)
FONT_OVERRIDE="* { font: \"Maple Mono NF ${FONT_SIZE}\"; }"

# ── Icon theme ────────────────────────────────────────────
ICON_OVERRIDE="configuration { icon-theme: \"Papirus-Dark\"; }"

# ── Launch mode ───────────────────────────────────────────
case "$1" in
    d|--drun|"")
        rofi -show drun \
            -theme "$ROFI_THEME" \
            -theme-str "$FONT_OVERRIDE" \
            -theme-str "$ICON_OVERRIDE" \
            -show-icons &
        disown
        ;;
    w|--window)
        rofi -show window \
            -theme "$ROFI_THEME" \
            -theme-str "$FONT_OVERRIDE" \
            -theme-str "$ICON_OVERRIDE" \
            -show-icons &
        disown
        ;;
    f|--filebrowser)
        rofi -show filebrowser \
            -theme "$ROFI_THEME" \
            -theme-str "$FONT_OVERRIDE" \
            -theme-str "$ICON_OVERRIDE" &
        disown
        ;;
    c|--clipboard)
        cliphist list | rofi -dmenu \
            -theme "$CLIP_THEME" \
            -theme-str "$FONT_OVERRIDE" \
            -p "  Clipboard" \
            | cliphist decode | wl-copy
        ;;
    *)
        echo "Usage: $(basename "$0") [d|w|f|c]"
        echo "  d — app launcher (drun)"
        echo "  w — window switcher"
        echo "  f — file browser"
        echo "  c — clipboard (cliphist)"
        exit 1
        ;;
esac
