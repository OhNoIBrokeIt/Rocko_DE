#!/usr/bin/env bash
# ~/.config/waybar/scripts/gpuinfo.sh
# NVIDIA GPU info — HyDE-style JSON with temp-XX and util-XX CSS classes

if ! command -v nvidia-smi &>/dev/null; then
  printf '{"text":"no gpu","tooltip":"nvidia-smi not found","class":""}\n'
  exit 0
fi

read -r GPU_UTIL GPU_TEMP GPU_MEM_USED GPU_MEM_TOTAL GPU_POWER < <(
  nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw \
    --format=csv,noheader,nounits 2>/dev/null \
    | awk -F', ' '{print $1, $2, $3, $4, $5}'
)

[[ -z "$GPU_UTIL" ]] && {
  printf '{"text":"gpu err","tooltip":"nvidia-smi failed","class":""}\n'
  exit 0
}

# Snap to buckets for CSS classes
TEMP_BUCKET=$(( (GPU_TEMP / 5) * 5 ))
UTIL_BUCKET=$(( (GPU_UTIL / 10) * 10 ))

# Icon
if   [ "$GPU_UTIL" -ge 90 ]; then ICON="󰒆"
elif [ "$GPU_UTIL" -ge 60 ]; then ICON="󰢮"
else ICON="󰍛"
fi

POWER_INT=${GPU_POWER%.*}
TEXT="${ICON} ${GPU_UTIL}%  ${GPU_TEMP}°C  ${GPU_MEM_USED}/${GPU_MEM_TOTAL}MB"
TOOLTIP="GPU Usage: ${GPU_UTIL}%\nTemperature: ${GPU_TEMP}°C\nVRAM: ${GPU_MEM_USED}/${GPU_MEM_TOTAL} MB\nPower: ${POWER_INT}W"
CLASS="temp-${TEMP_BUCKET} util-${UTIL_BUCKET}"

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
  "$TEXT" "$TOOLTIP" "$CLASS"
