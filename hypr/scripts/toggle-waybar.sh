#!/usr/bin/env bash
# ============================================================
#  toggle-waybar.sh
#  Toggles primary waybar (DP-2) only
#  Secondary (DP-3) always stays on — not OLED
# ============================================================

if systemctl --user is-active --quiet waybar.service; then
    systemctl --user stop waybar.service
else
    systemctl --user start waybar.service
fi
