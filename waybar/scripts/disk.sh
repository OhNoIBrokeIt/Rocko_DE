#!/usr/bin/env bash
# ~/.config/waybar/scripts/disk.sh
# Shows root partition usage, warns when getting full

MOUNT="${1:-/}"
USAGE=$(df -h "$MOUNT" 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%')
USED=$(df -h "$MOUNT" 2>/dev/null | awk 'NR==2 {print $3}')
TOTAL=$(df -h "$MOUNT" 2>/dev/null | awk 'NR==2 {print $2}')
AVAIL=$(df -h "$MOUNT" 2>/dev/null | awk 'NR==2 {print $4}')

if   [ "$USAGE" -ge 90 ]; then CLASS="critical"; ICON="󰪥"
elif [ "$USAGE" -ge 75 ]; then CLASS="warning";  ICON="󰋊"
else                            CLASS="normal";   ICON="󰋊"
fi

TEXT="${ICON} ${USED}/${TOTAL}"
TOOLTIP="Mount: ${MOUNT}\nUsed: ${USED} / ${TOTAL}\nFree: ${AVAIL}\nUsage: ${USAGE}%"

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
  "$TEXT" "$TOOLTIP" "$CLASS"
