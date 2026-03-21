#!/usr/bin/env bash
# ============================================================
#  Rocko_DE — Uninstall Script
#  Removes configs deployed by Rocko_DE deploy.sh
#  Does NOT uninstall packages (they may be used by other things)
# ============================================================

set -e

CONFIG="$HOME/.config"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}→${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠${NC} $1"; }

echo ""
echo -e "${RED}╔══════════════════════════════════════╗${NC}"
echo -e "${RED}║       Rocko_DE Uninstall             ║${NC}"
echo -e "${RED}╚══════════════════════════════════════╝${NC}"
echo ""
warn "This will remove Rocko_DE configs. Packages will NOT be removed."
warn "Backup anything you want to keep before continuing."
echo ""
read -rp "Continue? (y/N) " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# ── Stop services ──────────────────────────────────────────
info "Stopping services..."
systemctl --user stop waybar.service 2>/dev/null || true
systemctl --user disable waybar.service 2>/dev/null || true
systemctl --user stop hypridle.service 2>/dev/null || true
systemctl --user disable hypridle.service 2>/dev/null || true
pkill -x waybar 2>/dev/null || true
pkill -x hyprlock 2>/dev/null || true
pkill -x hypridle 2>/dev/null || true
pkill -x swaync 2>/dev/null || true
pkill -x pypr 2>/dev/null || true
pkill -f wallpaper-rotate 2>/dev/null || true
success "Services stopped"

# ── Remove systemd units ───────────────────────────────────
info "Removing systemd units..."
rm -f "$HOME/.config/systemd/user/waybar.service"
rm -f "$HOME/.config/systemd/user/waybar-resume.service"
rm -f "$HOME/.config/systemd/user/hypridle.service"
sudo rm -f /etc/systemd/system/waybar-resume.service 2>/dev/null || true
systemctl --user daemon-reload
success "Systemd units removed"

# ── Remove Hyprland config ─────────────────────────────────
info "Removing Hyprland config..."
rm -rf "$CONFIG/hypr"
success "Hyprland config removed"

# ── Remove Waybar ──────────────────────────────────────────
info "Removing Waybar config..."
rm -rf "$CONFIG/waybar"
success "Waybar config removed"

# ── Remove Rofi ────────────────────────────────────────────
info "Removing Rofi config..."
rm -rf "$CONFIG/rofi"
success "Rofi config removed"

# ── Remove Swaync ──────────────────────────────────────────
info "Removing Swaync config..."
rm -rf "$CONFIG/swaync"
success "Swaync config removed"

# ── Remove Wlogout ─────────────────────────────────────────
info "Removing Wlogout config..."
rm -rf "$CONFIG/wlogout"
success "Wlogout config removed"

# ── Remove Kitty ───────────────────────────────────────────
info "Removing Kitty config..."
rm -rf "$CONFIG/kitty"
success "Kitty config removed"

# ── Remove Fastfetch ───────────────────────────────────────
info "Removing Fastfetch config..."
rm -rf "$CONFIG/fastfetch"
success "Fastfetch config removed"

# ── Remove pyprland ────────────────────────────────────────
info "Removing pyprland config..."
rm -f "$CONFIG/pyprland.toml"
success "pyprland config removed"

# ── Remove wallbash / pywal colors ────────────────────────
info "Removing wallbash/pywal cache..."
rm -rf "$HOME/.config/wal"
rm -rf "$HOME/.cache/wallbash"
success "Color cache removed"

# ── Remove fish config ─────────────────────────────────────
info "Removing fish config..."
rm -rf "$CONFIG/fish"
success "Fish config removed"

# ── Remove greetd config ───────────────────────────────────
read -rp "Remove greetd config? This affects your login screen. (y/N) " greetd_confirm
if [[ "$greetd_confirm" =~ ^[Yy]$ ]]; then
    sudo rm -f /etc/greetd/config.toml
    sudo rm -f /etc/greetd/hyprland-greeter-config.conf
    success "greetd config removed"
else
    warn "Skipped greetd removal"
fi

# ── Remove wallpaper dirs (optional) ──────────────────────
read -rp "Remove wallpaper directories and wallpapers? (y/N) " wall_confirm
if [[ "$wall_confirm" =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/Pictures/Wallpapers"
    success "Wallpaper directories removed"
else
    warn "Skipped wallpaper removal — files kept"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       Rocko_DE uninstalled           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
warn "Packages were NOT removed. Run 'paru -Rns <package>' manually if needed."
warn "Reboot or restart Hyprland to complete cleanup."
