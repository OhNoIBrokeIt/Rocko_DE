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

read -r TEMP_C FEELS DESC HUMID WIND CODE < <(echo "$DATA" | python3 -c "
import sys, json
d = json.load(sys.stdin)
c = d['current_condition'][0]
print(
    c['temp_C'],
    c['FeelsLikeC'],
    c['weatherDesc'][0]['value'],
    c['humidity'],
    c['windspeedKmph'],
    c['weatherCode']
)
" 2>/dev/null)

get_icon() {
    local code="$1"
    case "$code" in
        113)                    echo "󰖙" ;;  # Sunny / Clear
        116)                    echo "󰖕" ;;  # Partly cloudy
        119|122)                echo "󰖔" ;;  # Cloudy / Overcast
        143|248|260)            echo "󰖑" ;;  # Mist / Fog
        176|263|266|293|296)    echo "󰦒" ;;  # Light rain / drizzle
        299|302|305|308)        echo "󰖗" ;;  # Moderate / heavy rain
        311|314|317|320)        echo "󰖗" ;;  # Freezing rain / sleet
        323|326|329|332)        echo "󰖘" ;;  # Light / moderate snow
        335|338|350|371|374)    echo "󰖘" ;;  # Heavy snow / blizzard
        377)                    echo "󰖘" ;;  # Ice pellets
        386|389)                echo "󰖈" ;;  # Rain with thunder
        392|395)                echo "󰖈" ;;  # Snow with thunder
        200)                    echo "󰖈" ;;  # Thundery outbreaks
        *)                      echo "󰖐" ;;  # Unknown
    esac
}

ICON=$(get_icon "$CODE")
TEMP_F=$(( (TEMP_C * 9 / 5) + 32 ))
FEELS_F=$(( (FEELS * 9 / 5) + 32 ))

TEXT="${ICON}  ${TEMP_F}°F"
TOOLTIP="${DESC}\nFeels like: ${FEELS_F}°F\nHumidity: ${HUMID}%\nWind: ${WIND} km/h\nLocation: ${LOCATION}"

RESULT=$(printf '{"text":"%s","tooltip":"%s","class":"weather"}\n' "$TEXT" "$TOOLTIP")
echo "$RESULT" | tee "$CACHE_FILE"
