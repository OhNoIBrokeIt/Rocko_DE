#!/usr/bin/env bash
# ~/.config/waybar/scripts/weather.sh
# Uses wttr.in — no API key needed
# Cached to avoid blocking waybar on slow/no network

LOCATION="Hollywood,FL"   # Change to your city, zip, or "City,State"
CACHE_FILE="$HOME/.cache/waybar-weather"
CACHE_MAX_AGE=1800  # 30 minutes

# ── Return cached result if fresh ────────────────────────
if [[ -f "$CACHE_FILE" ]] && [[ -n "$(find "$CACHE_FILE" -mmin -30 2>/dev/null)" ]]; then
    cat "$CACHE_FILE"
    [[ -z "$(find "$CACHE_FILE" -mmin -20 2>/dev/null)" ]] && ("$0" --refresh &>/dev/null &) &
    exit 0
fi

# ── First run with no cache — show placeholder ────────────
if [[ "$1" != "--refresh" ]] && [[ ! -f "$CACHE_FILE" ]]; then
    printf '{"text":"󰖐  --","tooltip":"Fetching weather...","class":"offline"}\n' | tee "$CACHE_FILE"
    ("$0" --refresh &>/dev/null &) &
    exit 0
fi

# ── Fetch with timeout ────────────────────────────────────
DATA=$(curl -sf --max-time 8 --connect-timeout 5 \
    "https://wttr.in/${LOCATION}?format=j1" 2>/dev/null)

if [[ -z "$DATA" ]]; then
    # Network failed — keep showing cached result if available
    # Don't overwrite cache with error
    if [[ -f "$CACHE_FILE" ]]; then
        cat "$CACHE_FILE"
    else
        printf '{"text":"󰖔  --","tooltip":"Weather unavailable","class":"offline"}\n'
    fi
    exit 0
fi

TEMP_C=$(echo "$DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['current_condition'][0]['temp_C'])" 2>/dev/null)
FEELS=$(echo "$DATA"  | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['current_condition'][0]['FeelsLikeC'])" 2>/dev/null)
DESC=$(echo "$DATA"   | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['current_condition'][0]['weatherDesc'][0]['value'])" 2>/dev/null)
HUMID=$(echo "$DATA"  | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['current_condition'][0]['humidity'])" 2>/dev/null)
WIND=$(echo "$DATA"   | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['current_condition'][0]['windspeedKmph'])" 2>/dev/null)

get_icon() {
    local desc="$1"
    case "$desc" in
        *Sunny*|*Clear*)     echo "󰖙" ;;
        *Partly*cloud*)      echo "󰖕" ;;
        *Cloud*|*Overcast*)  echo "󰖔" ;;
        *Rain*|*Drizzle*)    echo "󰖗" ;;
        *Thunder*|*Storm*)   echo "󰖈" ;;
        *Snow*|*Blizzard*)   echo "󰖘" ;;
        *Mist*|*Fog*)        echo "󰖑" ;;
        *)                   echo "󰖐" ;;
    esac
}

ICON=$(get_icon "$DESC")
TEMP_F=$(( (TEMP_C * 9 / 5) + 32 ))
FEELS_F=$(( (FEELS * 9 / 5) + 32 ))

TEXT="${ICON}  ${TEMP_F}°F"
TOOLTIP="${DESC}\nFeels like: ${FEELS_F}°F\nHumidity: ${HUMID}%\nWind: ${WIND} km/h\nLocation: ${LOCATION}"

RESULT=$(printf '{"text":"%s","tooltip":"%s","class":"weather"}\n' "$TEXT" "$TOOLTIP")
echo "$RESULT" | tee "$CACHE_FILE"
