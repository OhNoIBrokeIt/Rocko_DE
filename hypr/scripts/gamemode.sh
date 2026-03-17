#!/usr/bin/env bash
# ============================================================
#  gamemode.sh — Bind: Super+Alt+G
# ============================================================

WALLPAPER_SCRIPT="$HOME/.config/hypr/scripts/wallpaper-rotate.sh"
STATE_FILE="${HOME}/.cache/hypr-gamemode"
mkdir -p "${HOME}/.cache"

if [[ -f "$STATE_FILE" ]]; then
    # ── Exit game mode ────────────────────────────────────
    rm -f "$STATE_FILE"

    hyprctl -q --batch "\
        keyword animations:enabled 1;\
        keyword decoration:shadow:enabled 1;\
        keyword decoration:dim_inactive 1;\
        keyword decoration:dim_strength 0.08;\
        keyword decoration:rounding 12;\
        keyword general:gaps_in 6;\
        keyword general:gaps_out 12;\
        keyword general:border_size 2"

    # Restart wallpaper daemon after delay
    (sleep 3 && "$WALLPAPER_SCRIPT" &) &
    disown

    notify-send -a "Hyprland" -i input-gaming "Game Mode OFF" \
        "Full effects restored — wallpaper rotation resumed" -t 2000

else
    # ── Enter game mode ───────────────────────────────────
    touch "$STATE_FILE"

    hyprctl -q --batch "\
        keyword animations:enabled 0;\
        keyword decoration:shadow:enabled 0;\
        keyword decoration:dim_inactive 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"

    pkill -f "wallpaper-rotate.sh" 2>/dev/null

    notify-send -a "Hyprland" -i input-gaming "Game Mode ON" \
        "Effects disabled — wallpaper rotation paused" -t 2000
fi
