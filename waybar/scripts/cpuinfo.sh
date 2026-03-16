#!/usr/bin/env bash
# ~/.config/waybar/scripts/cpuinfo.sh
# Outputs HyDE-style JSON with temp-XX and util-XX CSS classes

CPU_TEMP=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null \
  | awk 'BEGIN{max=0} {v=$1/1000; if(v>max) max=v} END{printf "%d", max}')

CPU_UTIL=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1 2>/dev/null)
[[ -z "$CPU_UTIL" ]] && CPU_UTIL=$(grep -m1 'cpu ' /proc/stat | \
  awk '{idle=$5; total=0; for(i=2;i<=NF;i++) total+=$i; print int((total-idle)*100/total)}')

# Snap temp to nearest 5 for CSS class
TEMP_BUCKET=$(( (CPU_TEMP / 5) * 5 ))
# Snap util to nearest 10 for CSS class
UTIL_BUCKET=$(( (CPU_UTIL / 10) * 10 ))

# Icon changes with load
if   [ "$CPU_UTIL" -ge 90 ]; then ICON="󰣳"
elif [ "$CPU_UTIL" -ge 70 ]; then ICON="󰣴"
elif [ "$CPU_UTIL" -ge 50 ]; then ICON="󰣵"
else ICON="󰻠"
fi

TEXT="${ICON} ${CPU_UTIL}%  ${CPU_TEMP}°C"
TOOLTIP="CPU Usage: ${CPU_UTIL}%\nTemperature: ${CPU_TEMP}°C"
CLASS="temp-${TEMP_BUCKET} util-${UTIL_BUCKET}"

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
  "$TEXT" "$TOOLTIP" "$CLASS"
