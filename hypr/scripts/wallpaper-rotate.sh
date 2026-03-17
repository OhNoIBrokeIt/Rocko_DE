#!/usr/bin/env bash
# =========================================================
# wallpaper-rotate.sh — v2.0
# Per-monitor wallpaper rotation with swww + pywal
#
# Directory structure:
#   ~/Pictures/Wallpapers/ultrawide/   → DP-2 (5120x1440 OLED)
#   ~/Pictures/Wallpapers/4k/          → DP-3 (3840x2160)
#
# Usage:
#   wallpaper-rotate.sh              — start daemon loop
#   wallpaper-rotate.sh next         — rotate both monitors
#   wallpaper-rotate.sh next dp-2    — rotate only DP-2
#   wallpaper-rotate.sh next dp-3    — rotate only DP-3
#   wallpaper-rotate.sh set <path>   — set specific wallpaper
#   wallpaper-rotate.sh check        — verify directories
# =========================================================

WALLPAPER_BASE="/home/ohnoibrokeit/Pictures/Wallpapers"
DIR_ULTRAWIDE="$WALLPAPER_BASE/ultrawide"
DIR_4K="$WALLPAPER_BASE/4k"

MONITOR_ULTRAWIDE="DP-2"
MONITOR_4K="DP-3"

INTERVAL=300   # seconds between rotations (5 min)

TRANSITION_FLAGS=(
  --transition-type     fade
  --transition-duration 2
  --transition-fps      144
)

# ---- Output paths ----------------------------------------
WAYBAR_COLORS="$HOME/.config/waybar/colors-waybar.css"
HYPR_COLORS="$HOME/.config/wal/colors-hyprland.conf"
KITTY_COLORS="$HOME/.config/kitty/colors-wal.conf"
SWAYNC_COLORS="$HOME/.config/swaync/colors-wal.css"

# ---- State tracking — avoids repeating last wallpaper ----
STATE_DIR="$HOME/.cache/wallpaper-rotate"
mkdir -p "$STATE_DIR"

# ----------------------------------------------------------
# Pick a random wallpaper from a dir, avoid last used
# ----------------------------------------------------------
get_random() {
  local dir="$1"
  local last_file="$STATE_DIR/last_$(basename "$dir")"
  local last=""
  [[ -f "$last_file" ]] && last=$(cat "$last_file")

  mapfile -t candidates < <(
    find "$dir" -maxdepth 1 -type f \
      \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
      | grep -Fxv "$last"
  )

  if [[ ${#candidates[@]} -eq 0 ]]; then
    find "$dir" -maxdepth 1 -type f \
      \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
      | shuf -n 1
    return
  fi

  local chosen="${candidates[RANDOM % ${#candidates[@]}]}"
  echo "$chosen" > "$last_file"
  echo "$chosen"
}

# ----------------------------------------------------------
# Set wallpaper on a specific monitor
# ----------------------------------------------------------
set_monitor_wallpaper() {
  local monitor="$1"
  local wall="$2"

  if [[ -z "$wall" || ! -f "$wall" ]]; then
    echo "[$monitor] No wallpaper found — skipping"
    return 1
  fi

  swww img "$wall" --outputs "$monitor" "${TRANSITION_FLAGS[@]}"
  echo "[$monitor] → $(basename "$wall")"
}

# ----------------------------------------------------------
# Color helpers
# ----------------------------------------------------------
brightness_of() {
  local hex="${1/\#/}"
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  echo $(( (r*299 + g*587 + b*114) / 1000 ))
}

brighten_color() {
  local hex="${1/\#/}"
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  local brightness=$(( (r*299 + g*587 + b*114) / 1000 ))
  local min_brightness=130
  if (( brightness < min_brightness && brightness > 0 )); then
    local scale=$(( min_brightness * 100 / brightness ))
    r=$(( r * scale / 100 )); g=$(( g * scale / 100 )); b=$(( b * scale / 100 ))
    (( r > 255 )) && r=255; (( g > 255 )) && g=255; (( b > 255 )) && b=255
  fi
  printf '%02x%02x%02x' $r $g $b
}

saturation_score() {
  local hex="${1/\#/}"
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  local max=$r; (( g > max )) && max=$g; (( b > max )) && max=$b
  local min=$r; (( g < min )) && min=$g; (( b < min )) && min=$b
  if (( max == 0 )); then echo 0; return; fi
  local sat=$(( (max - min) * 255 / max ))
  local bri=$(( (r*299 + g*587 + b*114) / 1000 ))
  echo $(( sat * bri / 255 ))
}

# Blend two hex colors (hex1 at weight%, hex2 at (100-weight)%)
blend_hex() {
  local hex1="${1/\#/}" hex2="${2/\#/}" weight="${3:-50}"
  local r1=$((16#${hex1:0:2})) g1=$((16#${hex1:2:2})) b1=$((16#${hex1:4:2}))
  local r2=$((16#${hex2:0:2})) g2=$((16#${hex2:2:2})) b2=$((16#${hex2:4:2}))
  local r=$(( (r1 * weight + r2 * (100-weight)) / 100 ))
  local g=$(( (g1 * weight + g2 * (100-weight)) / 100 ))
  local b=$(( (b1 * weight + b2 * (100-weight)) / 100 ))
  printf '%02x%02x%02x' $r $g $b
}

# ----------------------------------------------------------
# Apply pywal and generate all color files
# ----------------------------------------------------------
apply_pywal() {
  local wall="$1"
  [[ -z "$wall" || ! -f "$wall" ]] && return 1

  nice -n 10 wal -i "$wall" -n --saturate 0.9 -q
  source "$HOME/.cache/wal/colors.sh" 2>/dev/null || return 1

  # Pick accent color — weighted by dominance + saturation
  # Colors earlier in pywal output are more dominant in the image.
  # We apply a dominance weight so a highly saturated but rare color
  # (like a small patch of neon green in foliage) doesn't win over
  # a moderately saturated color that defines the image mood.
  #
  # Weights: color1=100%, color2=85%, color3=70%, color4=60%,
  #          color5=50%, color6=45%, color9-14=35% (less dominant)
  local best_hex="${color1/\#/}"
  local best_score
  best_score=$(saturation_score "$color1")

  # Helper: weighted score
  weighted_score() {
    local color="$1" weight="$2"
    local s; s=$(saturation_score "$color")
    echo $(( s * weight / 100 ))
  }

  local ws
  ws=$(weighted_score "$color2" 85)
  (( ws > best_score )) && { best_score=$ws; best_hex="${color2/\#/}"; }
  ws=$(weighted_score "$color3" 70)
  (( ws > best_score )) && { best_score=$ws; best_hex="${color3/\#/}"; }
  ws=$(weighted_score "$color4" 60)
  (( ws > best_score )) && { best_score=$ws; best_hex="${color4/\#/}"; }
  ws=$(weighted_score "$color5" 50)
  (( ws > best_score )) && { best_score=$ws; best_hex="${color5/\#/}"; }
  ws=$(weighted_score "$color6" 45)
  (( ws > best_score )) && { best_score=$ws; best_hex="${color6/\#/}"; }
  for c in "$color9" "$color10" "$color11" "$color12" "$color13" "$color14"; do
    [[ -z "$c" ]] && continue
    ws=$(weighted_score "$c" 35)
    (( ws > best_score )) && { best_score=$ws; best_hex="${c/\#/}"; }
  done

  local accent_hex; accent_hex=$(brighten_color "$best_hex")
  local accent="#${accent_hex}"

  # Derive darker/lighter variants for the pill backgrounds
  local bg_hex="${background/\#/}"
  # main-bg: blend background toward dark with slight accent tint
  local main_bg_hex; main_bg_hex=$(blend_hex "$bg_hex" "0d0d18" 30)
  # hover bg: accent at very low alpha
  local c4="${color4/\#/}"

  # ── Waybar colors-waybar.css ──────────────────────────────
  # Full variable set for waybar v2 island style
  cat > "$WAYBAR_COLORS" << EOF
/* Auto-generated by wallpaper-rotate.sh — do not hand-edit */
/* Accent: ${accent} — from $(basename "$wall") */

@define-color bar-bg         rgba(0,0,0,0);
@define-color main-bg        alpha(${background}, 0.85);
@define-color main-fg        alpha(${foreground}, 0.90);
@define-color wb-act-bg      alpha(${accent}, 0.22);
@define-color wb-act-fg      ${accent};
@define-color wb-hvr-bg      alpha(${accent}, 0.12);
@define-color wb-hvr-fg      alpha(${accent}, 0.90);
@define-color wb-color       alpha(${foreground}, 0.60);
@define-color wb-act-color   ${accent};
@define-color wb-hvr-color   alpha(${accent}, 0.85);
@define-color border-color   alpha(${foreground}, 0.06);

/* Legacy names kept for compatibility */
@define-color accent         ${accent};
@define-color accent_alpha   alpha(${accent}, 0.80);
@define-color accent_dim     alpha(${accent}, 0.12);
@define-color accent_glow    alpha(${accent}, 0.25);
@define-color bg             ${background};
@define-color fg             ${foreground};
@define-color color1         ${color1};
@define-color color3         ${color3};
@define-color color4         ${color4};
EOF

  # ── Hyprland border colors (via hyprctl keyword — avoids config re-evaluation breaking blur) ──
  if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    hyprctl -q keyword general:col.active_border "rgba(${accent_hex}ee) rgba(${c4}aa) 45deg"
    hyprctl -q keyword general:col.inactive_border "rgba(1a1a2a55)"
  fi

  # ── Hyprlock accent ───────────────────────────────────────
  local c2fade="${accent_hex}44"
  local c2glow="${accent_hex}22"
  sed -i \
    -e "s/^\$accent     = .*$/\$accent     = rgba(${accent_hex}ff)/" \
    -e "s/^\$accentFade = .*$/\$accentFade = rgba(${c2fade})/" \
    -e "s/^\$accentGlow = .*$/\$accentGlow = rgba(${c2glow})/" \
    "$HOME/.config/hypr/hyprlock.conf" 2>/dev/null

  # ── Kitty colors ──────────────────────────────────────────
  cat > "$KITTY_COLORS" << EOF
# Auto-generated by wallpaper-rotate.sh — do not hand-edit
foreground            ${foreground}
background            ${background}
selection_foreground  ${background}
selection_background  ${accent}
cursor                ${accent}
cursor_text_color     ${background}
url_color             ${color4}
active_border_color   ${accent}
inactive_border_color ${color8}
active_tab_foreground   ${background}
active_tab_background   ${accent}
inactive_tab_foreground ${color7}
inactive_tab_background ${color0}
tab_bar_background      ${background}
color0  ${color0}
color1  ${color1}
color2  ${color2}
color3  ${color3}
color4  ${color4}
color5  ${color5}
color6  ${color6}
color7  ${color7}
color8  ${color8}
color9  ${color9}
color10 ${color10}
color11 ${color11}
color12 ${color12}
color13 ${color13}
color14 ${color14}
color15 ${color15}
EOF

  # ── Swaync colors ─────────────────────────────────────────
  local swaync_style="$HOME/.config/swaync/style.css"
  if [[ -f "$swaync_style" ]]; then
    sed -i '/^\/\* COLORS:START \*\//,/^\/\* COLORS:END \*\//d' "$swaync_style"
    local color_block
    color_block="/* COLORS:START */
@define-color accent     ${accent};
@define-color accent_dim alpha(${accent}, 0.15);
@define-color accent_mid alpha(${accent}, 0.55);
@define-color bg         alpha(${background}, 0.92);
@define-color fg         ${foreground};
/* COLORS:END */"
    echo "${color_block}" | cat - "$swaync_style" > /tmp/swaync-style-new.css \
      && mv /tmp/swaync-style-new.css "$swaync_style"
  fi

  # ── wlogout colors ────────────────────────────────────────
  local wlogout_style="$HOME/.config/wlogout/style.css"
  if [[ -f "$wlogout_style" ]]; then
    sed -i \
      -e "s|background-color: rgba(8, 8, 14, 0.88)|background-color: alpha(${background}, 0.88)|g" \
      -e "s|background-color: rgba(14, 14, 24, 0.85)|background-color: alpha(${background}, 0.85)|g" \
      -e "s|rgba(0, 210, 255,|alpha(${accent},|g" \
      "$wlogout_style" 2>/dev/null
  fi

  # ── Starship prompt ───────────────────────────────────────
  local starship_conf="$HOME/.config/starship.toml"
  if [[ -f "$starship_conf" ]]; then
    sed -i \
      -e "s|style = \"bold #[0-9a-fA-F]*\"|style = \"bold ${accent}\"|g" \
      -e "s|style = \"#[0-9a-fA-F]*\"|style = \"${accent}\"|g" \
      "$starship_conf"
    sed -i "s|error_symbol = \"[❯](bold ${accent})\"|error_symbol = \"[❯](bold #ff4c4c)\"|g" "$starship_conf"
  fi


  # ── Rofi wallbash ─────────────────────────────────────────
  # Regenerate theme.rasi with wallpaper-derived colors
  local rofi_theme="$HOME/.config/rofi/theme.rasi"
  if [[ -f "$rofi_theme" ]]; then
    cat > "$rofi_theme" << ROFI
/* Auto-generated by wallpaper-rotate.sh — do not hand-edit */
* {
    main-bg:        #${bg_hex}e6;
    main-fg:        #${accent_hex}e6;
    main-br:        #${accent_hex}e6;
    main-ex:        #${accent_hex}ff;
    select-bg:      #${accent_hex}80;
    select-fg:      #${bg_hex}ff;
    separatorcolor: transparent;
    border-color:   transparent;
}
ROFI
  fi

  # Regenerate rofi wall thumbnail + blur (square crop — no tiling in sidebar)
  # Run at low priority in background — no impact on gaming or foreground tasks
  local rofi_cache="$HOME/.cache/rofi"
  mkdir -p "$rofi_cache"
  if command -v magick &>/dev/null && [[ -f "$wall" ]]; then
    (
      nice -n 19 magick "$wall" -strip -resize 1000x1000^ -gravity center -extent 1000x1000 -quality 90 "$rofi_cache/wall.thumb" 2>/dev/null
      nice -n 19 magick "$wall" -strip -scale 10% -blur 0x3 -resize 100% "$rofi_cache/wall.blur" 2>/dev/null
      md5sum "$wall" | cut -d' ' -f1 > "$rofi_cache/wall.hash"
    ) &
    disown
  fi

  # ── Reload live processes ─────────────────────────────────
  # Waybar reloads itself via inotify (reload_style_on_change: true in config)
  # No external signal needed — writing colors-waybar.css triggers it automatically
  # hyprctl reload intentionally omitted — not needed for color changes
  if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    pkill -SIGUSR1 kitty 2>/dev/null
    sleep 1 && swaync-client -R && swaync-client -rs 2>/dev/null &
  fi



  echo "[pywal] Colors updated — accent: ${accent} — from $(basename "$wall")"
}

# ----------------------------------------------------------
# Rotate one or both monitors
# ----------------------------------------------------------
rotate() {
  if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    echo "[wallpaper] Hyprland not running, skipping rotation"
    return 0
  fi
  if ! swww query &>/dev/null; then
    echo "[wallpaper] swww-daemon not running, skipping rotation"
    return 0
  fi

  local target="${1:-both}"

  case "$target" in
    dp-2|ultrawide)
      local wall_uw; wall_uw=$(get_random "$DIR_ULTRAWIDE")
      set_monitor_wallpaper "$MONITOR_ULTRAWIDE" "$wall_uw"
      apply_pywal "$wall_uw"
      ;;
    dp-3|4k)
      local wall_4k; wall_4k=$(get_random "$DIR_4K")
      set_monitor_wallpaper "$MONITOR_4K" "$wall_4k"
      ;;
    both|*)
      local wall_uw wall_4k
      wall_uw=$(get_random "$DIR_ULTRAWIDE")
      wall_4k=$(get_random "$DIR_4K")
      set_monitor_wallpaper "$MONITOR_ULTRAWIDE" "$wall_uw"
      set_monitor_wallpaper "$MONITOR_4K"        "$wall_4k"
      apply_pywal "$wall_uw"
      ;;
  esac
}

# ----------------------------------------------------------
# Validate directories
# ----------------------------------------------------------
check_dirs() {
  echo "Checking wallpaper directories..."
  for dir in "$DIR_ULTRAWIDE" "$DIR_4K"; do
    if [[ ! -d "$dir" ]]; then
      echo "  MISSING: $dir"
    else
      local count
      count=$(find "$dir" -maxdepth 1 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
        | wc -l)
      echo "  OK: $dir ($count wallpaper(s))"
    fi
  done
}

# ----------------------------------------------------------
# Entry point
# ----------------------------------------------------------
case "$1" in
  next)
    rotate "${2:-both}"
    ;;
  resume)
    # Start daemon loop without initial rotation (used by gamemode restore)
    PIDFILE="$HOME/.cache/wallpaper-rotate/daemon.pid"
    mkdir -p "$(dirname "$PIDFILE")"
    if [[ -f "$PIDFILE" ]]; then
      OLD_PID=$(cat "$PIDFILE")
      if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "[wallpaper] Daemon already running (PID $OLD_PID), exiting"
        exit 0
      fi
    fi
    echo $$ > "$PIDFILE"
    trap "rm -f '$PIDFILE'" EXIT
    echo "Resuming wallpaper rotation daemon (no immediate rotate)"
    while true; do
      sleep "$INTERVAL"
      rotate both
    done
    ;;
  set)
    wall="$2"
    if [[ -z "$wall" || ! -f "$wall" ]]; then
      echo "Usage: $(basename "$0") set /path/to/wallpaper"
      exit 1
    fi
    if ! swww query &>/dev/null; then
      echo "[wallpaper] swww-daemon not running"
      exit 1
    fi
    set_monitor_wallpaper "$MONITOR_ULTRAWIDE" "$wall"
    set_monitor_wallpaper "$MONITOR_4K" "$wall"
    apply_pywal "$wall"
    ;;
  check)
    check_dirs
    ;;
  "")
    # ── Single instance lock ─────────────────────────────
    PIDFILE="$HOME/.cache/wallpaper-rotate/daemon.pid"
    mkdir -p "$(dirname "$PIDFILE")"
    if [[ -f "$PIDFILE" ]]; then
      OLD_PID=$(cat "$PIDFILE")
      if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "[wallpaper] Daemon already running (PID $OLD_PID), exiting"
        exit 0
      fi
    fi
    echo $$ > "$PIDFILE"
    trap "rm -f '$PIDFILE'" EXIT

    echo "Starting wallpaper rotation daemon (interval: ${INTERVAL}s)"
    check_dirs
    swww query &>/dev/null || sleep 3
    rotate both
    while true; do
      sleep "$INTERVAL"
      rotate both
    done
    ;;
  *)
    echo "Usage: $(basename "$0") [next [dp-2|dp-3|both]] | [set <path>] | [check]"
    exit 1
    ;;
esac
