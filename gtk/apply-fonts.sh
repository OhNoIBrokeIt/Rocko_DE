#!/usr/bin/env bash
# ============================================================
#  apply-fonts.sh
#  Sets CaskaydiaCove Nerd Font as UI font system-wide
#  and Maple Mono NF for terminal/monospace
#
#  Run once after installing ttf-cascadia-code-nerd
# ============================================================

UI_FONT="CaskaydiaCove Nerd Font 11"
MONO_FONT="Maple Mono NF 13"

echo "→ Applying fonts via gsettings..."

# GNOME / GTK settings via dconf
gsettings set org.gnome.desktop.interface font-name          "$UI_FONT"
gsettings set org.gnome.desktop.interface document-font-name "$UI_FONT"
gsettings set org.gnome.desktop.interface monospace-font-name "$MONO_FONT"
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0

echo "→ Writing GTK3 settings..."
GTK3_DIR="$HOME/.config/gtk-3.0"
mkdir -p "$GTK3_DIR"
cp "$(dirname "$0")/system/gtk3-settings.ini" "$GTK3_DIR/settings.ini"

echo "→ Writing GTK4 settings..."
GTK4_DIR="$HOME/.config/gtk-4.0"
mkdir -p "$GTK4_DIR"
cp "$(dirname "$0")/system/gtk4-settings.ini" "$GTK4_DIR/settings.ini"

echo "→ Updating kitty font..."
KITTY_CONF="$HOME/.config/kitty/kitty.conf"
if [[ -f "$KITTY_CONF" ]]; then
    sed -i \
        -e 's|^font_family.*|font_family      Maple Mono NF|' \
        -e 's|^bold_font.*|bold_font        Maple Mono NF Bold|' \
        -e 's|^italic_font.*|italic_font      Maple Mono NF Italic|' \
        -e 's|^bold_italic_font.*|bold_italic_font Maple Mono NF Bold Italic|' \
        -e 's|^font_size.*|font_size        13.0|' \
        "$KITTY_CONF"
    pkill -SIGUSR1 kitty 2>/dev/null
    echo "   Kitty updated and reloaded"
fi

echo "→ Reloading GTK apps..."
# Signal running GTK apps to reload their settings
if command -v xsettingsd &>/dev/null; then
    pkill -HUP xsettingsd 2>/dev/null
fi

echo ""
echo "✓ Fonts applied:"
echo "  UI/GTK:    $UI_FONT"
echo "  Terminal:  $MONO_FONT"
echo ""
echo "  Log out and back in for all GTK apps to pick up the change."
echo "  nwg-look will now show CaskaydiaCove as your UI font."
