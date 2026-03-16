#!/usr/bin/env bash
# ============================================================
#  gamemode.sh
#  ~/.config/hypr/scripts/gamemode.sh
#
#  Toggles Hyprland performance mode for gaming:
#    ON  — disables animations, blur, shadows, gaps, rounding
#    OFF — restores full config via hyprctl reload config-only
#
#  Bind: Super+F12 to toggle
#  Based on HyDE gamemode.sh
# ============================================================

HYPRGAMEMODE=$(hyprctl getoption animations:enabled | sed -n '1p' | awk '{print $2}')

if [ "$HYPRGAMEMODE" = 1 ]; then
    # ── Enter game mode ───────────────────────────────────
    # Disable all eye candy for maximum GPU headroom
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

    # Make all windows fully opaque
    hyprctl 'keyword windowrule opaque,class:(.*)'

    notify-send -a "Hyprland" -i input-gaming "Game Mode ON" \
        "Animations, blur and shadows disabled" -t 2000

else
    # ── Exit game mode ────────────────────────────────────
    # Restore full config from hyprland.conf
    hyprctl reload config-only -q

    notify-send -a "Hyprland" -i input-gaming "Game Mode OFF" \
        "Full desktop effects restored" -t 2000
fi
