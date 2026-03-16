#!/usr/bin/env bash
# ============================================================
#  gamemode.sh
#  ~/.config/hypr/scripts/gamemode.sh
#
#  Toggles Hyprland performance mode for gaming:
#    ON  — disables compositor effects, pauses wallpaper daemon
#    OFF — restores full config, resumes wallpaper daemon
#
#  Bind: Super+Alt+G
#  Based on HyDE gamemode.sh
# ============================================================

HYPRGAMEMODE=$(hyprctl getoption animations:enabled | sed -n '1p' | awk '{print $2}')
WALLPAPER_SCRIPT="$HOME/.config/hypr/scripts/wallpaper-rotate.sh"

if [ "$HYPRGAMEMODE" = 1 ]; then
    # ── Enter game mode ───────────────────────────────────
    hyprctl -q --batch "\
        keyword animations:enabled 0;\
        keyword decoration:shadow:enabled 0;\
        keyword decoration:blur:xray 1;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0;\
        keyword decoration:active_opacity 1;\
        keyword decoration:inactive_opacity 1;\
        keyword decoration:fullscreen_opacity 1;\
        keyword layerrule noanim,waybar;\
        keyword layerrule noanim,swaync-notification-window;\
        keyword layerrule noanim,swww-daemon;\
        keyword layerrule noanim,rofi"

    hyprctl 'keyword windowrule opaque,class:(.*)'

    # Pause wallpaper rotation daemon
    pkill -f "wallpaper-rotate.sh" 2>/dev/null
    echo "[gamemode] Wallpaper daemon stopped"

    notify-send -a "Hyprland" -i input-gaming "Game Mode ON" \
        "Effects disabled — wallpaper rotation paused" -t 2000

else
    # ── Exit game mode ────────────────────────────────────
    hyprctl reload config-only -q

    # Restart waybar so layer rules (blur/transparency) re-apply cleanly
    sleep 0.5 && systemctl --user restart waybar.service &

    # Resume wallpaper daemon
    "$WALLPAPER_SCRIPT" &
    disown
    echo "[gamemode] Wallpaper daemon restarted"

    notify-send -a "Hyprland" -i input-gaming "Game Mode OFF" \
        "Full effects restored — wallpaper rotation resumed" -t 2000
fi
