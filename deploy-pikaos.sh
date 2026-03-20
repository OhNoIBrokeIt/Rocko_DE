#!/usr/bin/env bash
# ============================================================
#  Rocko_DE — PikaOS Deploy Script
#  Fresh PikaOS Hyprland NVIDIA install setup
#
#  Usage:
#    git clone git@github.com:OhNoIBrokeIt/Rocko_DE.git
#    cd Rocko_DE && bash deploy-pikaos.sh
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
echo -e "${BLUE}║      Rocko_DE Deploy v2.0 — Pika     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# ── 1. Package Installation ───────────────────────────────
info "Installing apt packages..."

APT_PACKAGES=(
    # Bar
    waybar
    # Notifications
    sway-notification-center
    # Launcher
    rofi
    # Wallpaper
    swww
    imagemagick
    # Terminal (likely already installed)
    kitty
    # Editor
    neovim
    # File manager
    thunar
    tumbler
    ffmpegthumbnailer
    # Fonts
    fonts-noto
    fonts-noto-color-emoji
    # Icons
    papirus-icon-theme
    # Audio
    pipewire
    wireplumber
    pipewire-pulse
    pavucontrol
    playerctl
    # Network
    network-manager
    network-manager-gnome
    nm-connection-editor
    blueman
    # Clipboard
    cliphist
    wl-clipboard
    wl-clip-persist
    # Screenshot
    grim
    slurp
    swappy
    # Utilities
    xdg-user-dirs
    brightnessctl
    policykit-1-gnome
    kdeconnect
    swayimg
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
    # Python
    python3-pip
    pipx
)

sudo apt install -y --no-install-recommends "${APT_PACKAGES[@]}" 2>/dev/null || \
    warn "Some packages may have failed — check manually"

success "Apt packages installed"

# ── 2. Python packages ────────────────────────────────────
info "Installing Python packages..."

pip3 install pywal pyprland --break-system-packages 2>/dev/null || \
    warn "pip install failed — try manually: pip3 install pywal pyprland --break-system-packages"

success "Python packages installed"

# ── 3. Manual installs ────────────────────────────────────
info "Installing manual packages..."

# Catppuccin GTK theme
if [[ ! -d "/usr/share/themes/catppuccin-mocha-blue-standard+default" ]]; then
    info "Installing Catppuccin GTK theme..."
    CATPPUCCIN_URL="https://github.com/catppuccin/gtk/releases/download/v1.0.3/catppuccin-mocha-blue-standard+default.zip"
    wget -q "$CATPPUCCIN_URL" -O /tmp/catppuccin.zip 2>/dev/null || \
        warn "Could not download Catppuccin theme — install manually from https://github.com/catppuccin/gtk"
    if [[ -f /tmp/catppuccin.zip ]]; then
        sudo unzip -q /tmp/catppuccin.zip -d /usr/share/themes/
        rm /tmp/catppuccin.zip
        success "Catppuccin GTK theme installed"
    fi
else
    success "Catppuccin GTK theme already installed"
fi

# SDDM Sugar Candy theme
if [[ ! -d "/usr/share/sddm/themes/sugar-candy" ]]; then
    info "Installing SDDM Sugar Candy theme..."
    git clone --depth=1 https://github.com/Kangie/sddm-sugar-candy.git /tmp/sugar-candy 2>/dev/null || \
        warn "Could not clone sugar-candy — install manually"
    if [[ -d /tmp/sugar-candy ]]; then
        sudo mkdir -p /usr/share/sddm/themes && sudo cp -r /tmp/sugar-candy /usr/share/sddm/themes/sugar-candy
        rm -rf /tmp/sugar-candy
        success "SDDM Sugar Candy installed"
    fi
else
    success "SDDM Sugar Candy already installed"
fi

# Maple Mono NF font
if ! fc-list | grep -qi "maple mono"; then
    info "Installing Maple Mono NF font..."
    MAPLE_URL="https://github.com/subframe7536/maple-font/releases/download/v7.0/MapleMono-NF.zip"
    wget -q "$MAPLE_URL" -O /tmp/maplemono.zip 2>/dev/null || \
        warn "Could not download Maple Mono NF — install manually"
    if [[ -f /tmp/maplemono.zip ]]; then
        sudo mkdir -p /usr/share/fonts/MapleMono-NF
        sudo unzip -q /tmp/maplemono.zip -d /usr/share/fonts/MapleMono-NF/
        sudo fc-cache -f
        rm /tmp/maplemono.zip
        success "Maple Mono NF installed"
    fi
else
    success "Maple Mono NF already installed"
fi

# Nerd Font Symbols
if ! fc-list | grep -qi "symbols nerd"; then
    info "Installing Nerd Font Symbols..."
    NF_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/NerdFontsSymbolsOnly.zip"
    wget -q "$NF_URL" -O /tmp/nfsymbols.zip 2>/dev/null || \
        warn "Could not download Nerd Font Symbols — install manually"
    if [[ -f /tmp/nfsymbols.zip ]]; then
        sudo mkdir -p /usr/share/fonts/NerdFontsSymbolsOnly
        sudo unzip -q /tmp/nfsymbols.zip -d /usr/share/fonts/NerdFontsSymbolsOnly/
        sudo fc-cache -f
        rm /tmp/nfsymbols.zip
        success "Nerd Font Symbols installed"
    fi
else
    success "Nerd Font Symbols already installed"
fi

# qimgv image viewer
if ! command -v qimgv &>/dev/null; then
    warn "qimgv not available in apt — install manually from https://github.com/easymodo/qimgv or use swayimg as default"
else
    success "qimgv available"
fi

success "Manual installs complete"

# ── 4. Directory Structure ────────────────────────────────
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

# ── 5. Waybar ─────────────────────────────────────────────
info "Deploying waybar..."

cp "$SCRIPT_DIR/waybar/config.jsonc"  "$CONFIG/waybar/config.jsonc"
cp "$SCRIPT_DIR/waybar/style.css"     "$CONFIG/waybar/style.css"
cp "$SCRIPT_DIR/waybar/colors.css"    "$CONFIG/waybar/colors.css"
cp "$SCRIPT_DIR/waybar/scripts/"*     "$CONFIG/waybar/scripts/"
chmod +x "$CONFIG/waybar/scripts/"*

success "Waybar deployed"

# ── 6. Systemd Services ───────────────────────────────────
info "Installing systemd services..."

cp "$SCRIPT_DIR/systemd/waybar.service"        "$CONFIG/systemd/user/waybar.service"
cp "$SCRIPT_DIR/systemd/waybar-resume.service" "$CONFIG/systemd/user/waybar-resume.service"

systemctl --user daemon-reload
systemctl --user enable waybar.service

sudo cp "$SCRIPT_DIR/systemd/waybar-resume.service" /etc/systemd/system/waybar-resume.service
sudo systemctl daemon-reload
sudo systemctl enable waybar-resume.service

success "Systemd services installed"

# ── 7. Rofi ───────────────────────────────────────────────
info "Deploying rofi..."

cp "$SCRIPT_DIR/rofi/theme.rasi"            "$CONFIG/rofi/theme.rasi"
cp "$SCRIPT_DIR/rofi/themes/style_1.rasi"   "$CONFIG/rofi/themes/style_1.rasi"
cp "$SCRIPT_DIR/rofi/themes/clipboard.rasi" "$CONFIG/rofi/themes/clipboard.rasi"
cp "$SCRIPT_DIR/rofi/rofilaunch.sh"         "$CONFIG/hypr/scripts/rofilaunch.sh"
chmod +x "$CONFIG/hypr/scripts/rofilaunch.sh"

success "Rofi deployed"

# ── 8. Hyprland ───────────────────────────────────────────
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

touch "$CONFIG/wal/colors-hyprland.conf"

success "Hyprland deployed"

# ── 9. Pyprland ───────────────────────────────────────────
info "Deploying pyprland..."
cp "$SCRIPT_DIR/pypr/config.toml" "$CONFIG/pypr/config.toml"
success "Pyprland deployed"

# ── 10. Neovim ────────────────────────────────────────────
info "Deploying neovim config..."
mkdir -p "$CONFIG/nvim/lua/config"
mkdir -p "$CONFIG/nvim/lua/plugins"
cp "$SCRIPT_DIR/nvim/init.lua"       "$CONFIG/nvim/init.lua"
cp "$SCRIPT_DIR/nvim/lua/config/"*   "$CONFIG/nvim/lua/config/"
cp "$SCRIPT_DIR/nvim/lua/plugins/"*  "$CONFIG/nvim/lua/plugins/"
success "Neovim deployed"

# ── 11. Fastfetch ─────────────────────────────────────────
info "Deploying fastfetch..."
mkdir -p "$CONFIG/fastfetch"
cp "$SCRIPT_DIR/fastfetch/config.jsonc" "$CONFIG/fastfetch/config.jsonc"
cp "$SCRIPT_DIR/fastfetch/avatar.png"   "$CONFIG/fastfetch/avatar.png"
success "Fastfetch deployed"

# ── 12. Swaync ────────────────────────────────────────────
info "Deploying swaync..."
cp "$SCRIPT_DIR/swaync/config.json" "$CONFIG/swaync/config.json"
cp "$SCRIPT_DIR/swaync/style.css"   "$CONFIG/swaync/style.css"
success "Swaync deployed"

# ── 13. Wlogout ───────────────────────────────────────────
info "Deploying wlogout..."
cp "$SCRIPT_DIR/wlogout/layout"    "$CONFIG/wlogout/layout"
cp "$SCRIPT_DIR/wlogout/style.css" "$CONFIG/wlogout/style.css"
success "Wlogout deployed"

# ── 14. Kitty ─────────────────────────────────────────────
info "Deploying kitty config..."
cp "$SCRIPT_DIR/kitty/kitty.conf" "$CONFIG/kitty/kitty.conf"
success "Kitty deployed"

# ── 15. GTK / Fonts / Icons ───────────────────────────────
info "Applying GTK settings, fonts, and icons..."

cp "$SCRIPT_DIR/gtk/gtk3-settings.ini" "$CONFIG/gtk-3.0/settings.ini"
cp "$SCRIPT_DIR/gtk/gtk4-settings.ini" "$CONFIG/gtk-4.0/settings.ini"

gsettings set org.gnome.desktop.interface gtk-theme           'catppuccin-mocha-blue-standard+default' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme          'Papirus-Dark'                           2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-theme        'Adwaita'                                2>/dev/null || true
gsettings set org.gnome.desktop.interface font-name           'Maple Mono NF 11'                       2>/dev/null || true
gsettings set org.gnome.desktop.interface document-font-name  'Maple Mono NF 11'                       2>/dev/null || true
gsettings set org.gnome.desktop.interface monospace-font-name 'Maple Mono NF 13'                       2>/dev/null || true

# Set default image viewer
xdg-mime default qimgv.desktop image/jpeg 2>/dev/null || xdg-mime default swayimg.desktop image/jpeg || true
xdg-mime default qimgv.desktop image/png  2>/dev/null || xdg-mime default swayimg.desktop image/png  || true
xdg-mime default qimgv.desktop image/webp 2>/dev/null || xdg-mime default swayimg.desktop image/webp || true
xdg-mime default qimgv.desktop image/gif  2>/dev/null || xdg-mime default swayimg.desktop image/gif  || true

success "GTK settings applied"

# ── 16. Fish shell ────────────────────────────────────────
info "Setting fish as default shell..."
if command -v fish &>/dev/null; then
    FISH_PATH=$(which fish)
    if ! grep -q "$FISH_PATH" /etc/shells; then
        echo "$FISH_PATH" | sudo tee -a /etc/shells
    fi
    sudo usermod -s "$FISH_PATH" "$USER" 2>/dev/null || \
        chsh -s "$FISH_PATH" 2>/dev/null || \
        warn "Could not change shell — run: chsh -s $(which fish)"
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
        fi
        if ! grep -q "starship init fish" "$FISH_CONFIG"; then
            echo 'starship init fish | source' >> "$FISH_CONFIG"
        fi
    else
        cat > "$FISH_CONFIG" << 'FISHEOF'
if status is-interactive
    fastfetch
end
starship init fish | source
FISHEOF
    fi
    success "Fish configured"
else
    warn "Fish not installed"
fi

# Starship for bash and zsh
if ! grep -q "starship init bash" "$USER_HOME/.bashrc" 2>/dev/null; then
    echo 'eval "$(starship init bash)"' >> "$USER_HOME/.bashrc"
fi
if ! grep -q "starship init zsh" "$USER_HOME/.zshrc" 2>/dev/null; then
    echo 'eval "$(starship init zsh)"' >> "$USER_HOME/.zshrc" 2>/dev/null || true
fi
success "Starship configured for all shells"

# Ensure ~/.local/bin is in PATH for pip-installed tools
if ! grep -q ".local/bin" "$USER_HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$USER_HOME/.bashrc"
fi
if ! grep -q ".local/bin" "$USER_HOME/.zshrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$USER_HOME/.zshrc" 2>/dev/null || true
fi
success "PATH updated for pip-installed tools"

# ── 17. SDDM ──────────────────────────────────────────────
info "Configuring SDDM..."

sudo systemctl disable lightdm 2>/dev/null || true
sudo systemctl disable gdm     2>/dev/null || true
sudo systemctl enable sddm

if [[ -d "/usr/share/sddm/themes/sugar-candy" ]]; then
    sudo cp "$SCRIPT_DIR/sddm/theme.conf" /usr/share/sddm/themes/sugar-candy/theme.conf
    sudo cp "$SCRIPT_DIR/sddm/Backgrounds/"* /usr/share/sddm/themes/sugar-candy/Backgrounds/
    sudo mkdir -p /etc/sddm.conf.d
    sudo cp "$SCRIPT_DIR/sddm/sddm.conf" /etc/sddm.conf.d/theme.conf
    success "SDDM sugar-candy configured"
else
    warn "SDDM sugar-candy not found — configure manually"
fi

# ── 18. Apt hook (replaces pacman hook) ───────────────────
info "Installing apt hook for waybar update count..."

sudo tee /etc/apt/apt.conf.d/99-waybar-updates > /dev/null << 'EOF'
DPkg::Post-Invoke {
    "sleep 2 && rm -f /home/$USER/.cache/waybar-updates && pkill -RTMIN+8 waybar || true";
};
EOF

success "Apt hook installed"

# ── 19. Final setup ───────────────────────────────────────
info "Running initial wallpaper setup..."
if [[ -n "$(find "$HOME/Pictures/Wallpapers/ultrawide" -type f 2>/dev/null | head -1)" ]]; then
    warn "Run this after first login: ~/.config/hypr/scripts/wallpaper-rotate.sh next"
else
    warn "No wallpapers found — add images to ~/Pictures/Wallpapers/ultrawide/ and ~/Pictures/Wallpapers/4k/"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      Rocko_DE Deploy Done — Pika!    ║${NC}"
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
