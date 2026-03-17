#!/usr/bin/env bash
# ============================================================
#  Rocko_DE — Full Deploy Script
#  Fresh CachyOS install setup
#
#  Usage:
#    # From GitHub:
#    git clone https://github.com/OhNoIBrokeIt/Rocko_DE.git
#    cd Rocko_DE && bash deploy.sh
#
#    # From zip:
#    unzip Rocko_DE.zip
#    cd Rocko_DE && bash deploy.sh
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)"
USER_HOME="$HOME"
CONFIG="$USER_HOME/.config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}→${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠${NC} $1"; }
error()   { echo -e "${RED}✗${NC} $1"; }

echo ""
echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Rocko_DE Deploy v2.0         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# ── 1. Package Installation ───────────────────────────────
info "Installing packages..."

PACKAGES=(
    # Hyprland ecosystem
    hyprland hyprlock hypridle hyprpicker
    xdg-desktop-portal-hyprland
    # Bar
    waybar
    # Notifications
    swaync
    # Launcher
    rofi-wayland
    # Logout
    wlogout
    # Wallpaper
    swww
    python-pywal
    imagemagick
    # Terminal
    kitty
    # Editor
    neovim
    # File manager
    yazi
    thunar
    # Fonts
    ttf-maple
    ttf-cascadia-code-nerd
    ttf-nerd-fonts-symbols
    ttf-nerd-fonts-symbols-mono
    ttf-nerd-fonts-symbols-common
    # Icons
    papirus-icon-theme
    # Audio
    pipewire wireplumber pipewire-pulse
    pavucontrol
    playerctl
    # Network
    networkmanager network-manager-applet
    nm-connection-editor
    blueman
    # Clipboard
    cliphist wl-clipboard
    # Screenshot
    grim slurp swappy
    # Utilities
    wl-color-picker
    brightnessctl
    polkit-gnome
    kdeconnect
    # GTK theming
    nwg-look
    qt6ct
    kvantum
    # Shell
    fish
    starship
    # Display manager
    sddm
    # Fetch
    fastfetch
)

AUR_PACKAGES=(
    pyprland
    catppuccin-gtk-theme-mocha
)

info "Installing official packages..."
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}" 2>/dev/null || \
    warn "Some packages may have failed — check manually"

info "Installing AUR packages..."
if command -v paru &>/dev/null; then
    paru -S --needed --noconfirm "${AUR_PACKAGES[@]}" 2>/dev/null || \
        warn "Some AUR packages may have failed — check manually"
else
    warn "paru not found — install it first: https://github.com/Morganamilo/paru"
    warn "Then run: paru -S ${AUR_PACKAGES[*]}"
fi

success "Packages installed"

# ── 2. Directory Structure ────────────────────────────────
info "Creating directory structure..."

mkdir -p "$CONFIG/waybar/scripts"
mkdir -p "$CONFIG/rofi/themes"
mkdir -p "$CONFIG/hypr/scripts"
mkdir -p "$CONFIG/hypr/conf"
mkdir -p "$CONFIG/systemd/user"
mkdir -p "$CONFIG/swaync"
mkdir -p "$CONFIG/wlogout"
mkdir -p "$CONFIG/gtk-3.0"
mkdir -p "$CONFIG/gtk-4.0"
mkdir -p "$CONFIG/pypr"
mkdir -p "$CONFIG/wal"
mkdir -p "$CONFIG/kitty"
mkdir -p "$HOME/Pictures/Wallpapers/ultrawide"
mkdir -p "$HOME/Pictures/Wallpapers/4k"
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/.cache/waybar"
mkdir -p "$HOME/.cache/rofi"
mkdir -p "$HOME/.cache/wallpaper-rotate"

success "Directories created"
info "Add wallpapers to:"
echo "   ~/Pictures/Wallpapers/ultrawide/  — DP-2 (5120x1440)"
echo "   ~/Pictures/Wallpapers/4k/         — DP-3 (3840x2160)"

# ── 3. Waybar ─────────────────────────────────────────────
info "Deploying waybar (single instance — all monitors)..."

cp "$SCRIPT_DIR/waybar/config.jsonc"  "$CONFIG/waybar/config.jsonc"
cp "$SCRIPT_DIR/waybar/style.css"     "$CONFIG/waybar/style.css"
cp "$SCRIPT_DIR/waybar/colors.css"    "$CONFIG/waybar/colors.css"
cp "$SCRIPT_DIR/waybar/scripts/"*     "$CONFIG/waybar/scripts/"
chmod +x "$CONFIG/waybar/scripts/"*

success "Waybar deployed"

# ── 4. Systemd Services ───────────────────────────────────
info "Installing systemd services..."

cp "$SCRIPT_DIR/systemd/waybar.service"        "$CONFIG/systemd/user/waybar.service"
cp "$SCRIPT_DIR/systemd/waybar-resume.service" "$CONFIG/systemd/user/waybar-resume.service"

systemctl --user daemon-reload
systemctl --user enable waybar.service

# waybar-resume needs system scope (suspend.target lives there)
sudo cp "$SCRIPT_DIR/systemd/waybar-resume.service" /etc/systemd/system/waybar-resume.service
sudo systemctl daemon-reload
sudo systemctl enable waybar-resume.service

success "Systemd services installed"

# ── 5. Rofi ───────────────────────────────────────────────
info "Deploying rofi..."

cp "$SCRIPT_DIR/rofi/theme.rasi"            "$CONFIG/rofi/theme.rasi"
cp "$SCRIPT_DIR/rofi/themes/style_1.rasi"   "$CONFIG/rofi/themes/style_1.rasi"
cp "$SCRIPT_DIR/rofi/themes/clipboard.rasi" "$CONFIG/rofi/themes/clipboard.rasi"
cp "$SCRIPT_DIR/rofi/rofilaunch.sh"         "$CONFIG/hypr/scripts/rofilaunch.sh"
chmod +x "$CONFIG/hypr/scripts/rofilaunch.sh"

success "Rofi deployed"

# ── 6. Hyprland ───────────────────────────────────────────
info "Deploying hyprland configs..."

cp "$SCRIPT_DIR/hypr/hyprland.conf"                  "$CONFIG/hypr/hyprland.conf"
cp "$SCRIPT_DIR/hypr/hyprlock.conf"                  "$CONFIG/hypr/hyprlock.conf"
cp "$SCRIPT_DIR/hypr/hypridle.conf"                  "$CONFIG/hypr/hypridle.conf"
cp "$SCRIPT_DIR/hypr/scripts/wallpaper-rotate.sh"    "$CONFIG/hypr/scripts/wallpaper-rotate.sh"
cp "$SCRIPT_DIR/hypr/scripts/toggle-waybar.sh"       "$CONFIG/hypr/scripts/toggle-waybar.sh"
cp "$SCRIPT_DIR/hypr/scripts/keybind-cheatsheet.sh"  "$CONFIG/hypr/scripts/keybind-cheatsheet.sh"
cp "$SCRIPT_DIR/hypr/scripts/gamemode.sh"            "$CONFIG/hypr/scripts/gamemode.sh"
chmod +x "$CONFIG/hypr/scripts/"*

cp "$SCRIPT_DIR/hypr/conf/monitors.conf"    "$CONFIG/hypr/conf/monitors.conf"
cp "$SCRIPT_DIR/hypr/conf/animations.conf"  "$CONFIG/hypr/conf/animations.conf"
cp "$SCRIPT_DIR/hypr/conf/windowrules.conf" "$CONFIG/hypr/conf/windowrules.conf"
cp "$SCRIPT_DIR/hypr/conf/keybinds.conf"    "$CONFIG/hypr/conf/keybinds.conf"

# Pywal color file — empty on first run, populated by wallpaper-rotate.sh
touch "$CONFIG/wal/colors-hyprland.conf"

success "Hyprland deployed"

# ── 7. Pyprland ───────────────────────────────────────────
info "Deploying pyprland..."
cp "$SCRIPT_DIR/pypr/config.toml" "$CONFIG/pypr/config.toml"
success "Pyprland deployed"

# ── 8. Neovim ─────────────────────────────────────────────
info "Deploying neovim config..."
mkdir -p "$CONFIG/nvim/lua/config"
mkdir -p "$CONFIG/nvim/lua/plugins"
cp "$SCRIPT_DIR/nvim/init.lua"       "$CONFIG/nvim/init.lua"
cp "$SCRIPT_DIR/nvim/lua/config/"*   "$CONFIG/nvim/lua/config/"
cp "$SCRIPT_DIR/nvim/lua/plugins/"*  "$CONFIG/nvim/lua/plugins/"
success "Neovim deployed"

# ── 9. Fastfetch ──────────────────────────────────────────
info "Deploying fastfetch..."
mkdir -p "$CONFIG/fastfetch"
cp "$SCRIPT_DIR/fastfetch/config.jsonc" "$CONFIG/fastfetch/config.jsonc"
cp "$SCRIPT_DIR/fastfetch/avatar.png"   "$CONFIG/fastfetch/avatar.png"
success "Fastfetch deployed"

# ── 10. Swaync ────────────────────────────────────────────
info "Deploying swaync..."
cp "$SCRIPT_DIR/swaync/config.json" "$CONFIG/swaync/config.json"
cp "$SCRIPT_DIR/swaync/style.css"   "$CONFIG/swaync/style.css"
success "Swaync deployed"

# ── 11. Wlogout ───────────────────────────────────────────
info "Deploying wlogout..."
cp "$SCRIPT_DIR/wlogout/layout"    "$CONFIG/wlogout/layout"
cp "$SCRIPT_DIR/wlogout/style.css" "$CONFIG/wlogout/style.css"
success "Wlogout deployed"

# ── 12. GTK / Fonts ───────────────────────────────────────
info "Applying GTK settings and fonts..."

cp "$SCRIPT_DIR/gtk/gtk3-settings.ini" "$CONFIG/gtk-3.0/settings.ini"
cp "$SCRIPT_DIR/gtk/gtk4-settings.ini" "$CONFIG/gtk-4.0/settings.ini"

gsettings set org.gnome.desktop.interface font-name           "CaskaydiaCove Nerd Font 11" 2>/dev/null || true
gsettings set org.gnome.desktop.interface document-font-name  "CaskaydiaCove Nerd Font 11" 2>/dev/null || true
gsettings set org.gnome.desktop.interface monospace-font-name "Maple Mono NF 13"           2>/dev/null || true

success "GTK settings applied"

# ── 13. Kitty ─────────────────────────────────────────────
info "Deploying kitty config..."

KITTY_CONF="$CONFIG/kitty/kitty.conf"

if [[ ! -f "$KITTY_CONF" ]]; then
    cat > "$KITTY_CONF" << 'KITTYEOF'
# Kitty config — Rocko_DE
font_family      Maple Mono NF
bold_font        Maple Mono NF Bold
italic_font      Maple Mono NF Italic
bold_italic_font Maple Mono NF Bold Italic
font_size        13.0

# Pywal colors
include ~/.cache/wal/colors-kitty.conf
KITTYEOF
    success "Kitty config created"
else
    sed -i \
        -e 's|^font_family.*|font_family      Maple Mono NF|' \
        -e 's|^bold_font.*|bold_font        Maple Mono NF Bold|' \
        -e 's|^italic_font.*|italic_font      Maple Mono NF Italic|' \
        -e 's|^bold_italic_font.*|bold_italic_font Maple Mono NF Bold Italic|' \
        -e 's|^font_size.*|font_size        13.0|' \
        "$KITTY_CONF"
    success "Kitty font updated"
fi

# ── 14. Fish shell ────────────────────────────────────────
info "Setting fish as default shell..."
if command -v fish &>/dev/null; then
    FISH_PATH=$(which fish)
    if ! grep -q "$FISH_PATH" /etc/shells; then
        echo "$FISH_PATH" | sudo tee -a /etc/shells
    fi
    chsh -s "$FISH_PATH" 2>/dev/null || warn "Could not change shell — run: chsh -s $(which fish)"
    success "Fish set as default shell"

    FISH_CONFIG="$USER_HOME/.config/fish/config.fish"
    mkdir -p "$(dirname "$FISH_CONFIG")"
    if [[ -f "$FISH_CONFIG" ]]; then
        if ! grep -q 'fastfetch' "$FISH_CONFIG"; then
            echo '' >> "$FISH_CONFIG"
            echo '# Launch fastfetch on terminal open' >> "$FISH_CONFIG"
            echo 'if status is-interactive' >> "$FISH_CONFIG"
            echo '    fastfetch' >> "$FISH_CONFIG"
            echo 'end' >> "$FISH_CONFIG"
            success "Fastfetch added to fish startup"
        fi
    else
        cat > "$FISH_CONFIG" << 'FISHEOF'
# Launch fastfetch on terminal open
if status is-interactive
    fastfetch
end
FISHEOF
        success "Fish config created with fastfetch"
    fi
else
    warn "Fish not installed"
fi

# ── 15. SDDM ──────────────────────────────────────────────
info "Configuring SDDM..."

sudo systemctl disable lightdm 2>/dev/null || true
sudo systemctl disable gdm     2>/dev/null || true
sudo systemctl disable greetd  2>/dev/null || true
sudo systemctl enable sddm

success "SDDM enabled"

# ── 16. Final setup ───────────────────────────────────────
info "Running initial wallpaper setup..."
if [[ -n "$(find "$HOME/Pictures/Wallpapers/ultrawide" -type f 2>/dev/null | head -1)" ]]; then
    warn "Run this after first login: ~/.config/hypr/scripts/wallpaper-rotate.sh next"
else
    warn "No wallpapers found — add images to ~/Pictures/Wallpapers/ultrawide/ and ~/Pictures/Wallpapers/4k/"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         Rocko_DE Deploy Done!        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo "  Next steps:"
echo "  1. Add wallpapers to ~/Pictures/Wallpapers/ultrawide/ and ~/Pictures/Wallpapers/4k/"
echo "  2. Log out and log back in (or reboot)"
echo "  3. On first login run: ~/.config/hypr/scripts/wallpaper-rotate.sh next"
echo "  4. Run nwg-look to confirm GTK theme"
echo ""
echo "  Key bindings:"
echo "  Super+R          — App launcher"
echo "  Super+\`          — Drop-down terminal"
echo "  Super+F1         — Drop-down file manager"
echo "  Super+/          — Keybind cheatsheet"
echo "  Super+Shift+W    — Rotate wallpaper"
echo ""
