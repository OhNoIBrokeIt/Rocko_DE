#!/usr/bin/env bash
# ~/.config/waybar/scripts/updates.sh
# PikaOS / Debian apt update count — cached to avoid blocking waybar

CACHE_FILE="$HOME/.cache/waybar-updates"

if [[ "$1" != "--refresh" ]] && [[ -f "$CACHE_FILE" ]] && [[ -n "$(find "$CACHE_FILE" -mmin -60 2>/dev/null)" ]]; then
    cat "$CACHE_FILE"
    [[ -z "$(find "$CACHE_FILE" -mmin -45 2>/dev/null)" ]] && ("$0" --refresh &>/dev/null &) &
    exit 0
fi

if [[ "$1" != "--refresh" ]] && [[ ! -f "$CACHE_FILE" ]]; then
    printf '{"text":"󰚰 ...","tooltip":"Checking for updates...","class":"checking"}\n' | tee "$CACHE_FILE"
    ("$0" --refresh &>/dev/null &) &
    exit 0
fi

TOTAL=$(apt list --upgradable 2>/dev/null | grep -v "^Listing" | grep "[upgradable]" | wc -l)

if [ "$TOTAL" -eq 0 ]; then
    TEXT=""
    CLASS="updated"
    TOOLTIP="System is up to date"
elif [ "$TOTAL" -ge 20 ]; then
    TEXT=" ${TOTAL} updates"
    CLASS="critical"
    TOOLTIP="${TOTAL} updates available\nClick to update"
else
    TEXT=" ${TOTAL}"
    CLASS="available"
    TOOLTIP="${TOTAL} updates available\nClick to update"
fi

RESULT=$(printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$TEXT" "$TOOLTIP" "$CLASS")
echo "$RESULT" | tee "$CACHE_FILE"
