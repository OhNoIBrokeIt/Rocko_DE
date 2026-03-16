#!/usr/bin/env bash
# ~/.config/waybar/scripts/updates.sh
# CachyOS / Arch update count — cached to avoid blocking waybar
#
# Cache strategy:
#   - Result cached for 1 hour in ~/.cache/waybar-updates
#   - Cache refreshed in background so waybar never blocks
#   - On-click in waybar triggers immediate refresh + kitty update

CACHE_FILE="$HOME/.cache/waybar-updates"
CACHE_MAX_AGE=3600  # 1 hour in seconds

# ── Return cached result if fresh (uses find — no subprocesses) ──
if [[ -f "$CACHE_FILE" ]] && [[ -n "$(find "$CACHE_FILE" -mmin -60 2>/dev/null)" ]]; then
    cat "$CACHE_FILE"
    # Refresh in background if getting stale (>45 min)
    [[ -z "$(find "$CACHE_FILE" -mmin -45 2>/dev/null)" ]] && ("$0" --refresh &>/dev/null &) &
    exit 0
fi

# ── Fetch fresh count ─────────────────────────────────────
# If called with --refresh, run fully and update cache
# Otherwise show stale/loading state while refreshing in bg
if [[ "$1" != "--refresh" ]] && [[ ! -f "$CACHE_FILE" ]]; then
    # First run — show loading, refresh in background
    printf '{"text":"󰚰 ...","tooltip":"Checking for updates...","class":"checking"}\n' | tee "$CACHE_FILE"
    ("$0" --refresh &>/dev/null &) &
    exit 0
fi

OFFICIAL=$(checkupdates 2>/dev/null | wc -l)

if command -v paru &>/dev/null; then
    AUR=$(paru -Qua 2>/dev/null | wc -l)
else
    AUR=0
fi

TOTAL=$(( OFFICIAL + AUR ))

if [ "$TOTAL" -eq 0 ]; then
    TEXT="󰮯 up to date"
    CLASS="updated"
    TOOLTIP="System is up to date"
elif [ "$TOTAL" -ge 20 ]; then
    TEXT="󰚰 ${TOTAL} updates"
    CLASS="critical"
    TOOLTIP="Updates available: ${OFFICIAL} official, ${AUR} AUR\nClick to update"
else
    TEXT="󰚰 ${TOTAL}"
    CLASS="available"
    TOOLTIP="Updates available: ${OFFICIAL} official, ${AUR} AUR\nClick to update"
fi

RESULT=$(printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$TEXT" "$TOOLTIP" "$CLASS")
echo "$RESULT" | tee "$CACHE_FILE"
