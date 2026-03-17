# Rocko_DE — Hyprland Desktop Environment Config

## Quick Start — Fresh CachyOS Install

```bash
git clone git@github.com:OhNoIBrokeIt/Rocko_DE.git && cd Rocko_DE && bash deploy.sh
```

The deploy script will:
1. Install all required packages via pacman + paru
2. Deploy all configs to the correct locations
3. Enable systemd services (waybar, waybar-resume)
4. Enable SDDM display manager
5. Set fonts system-wide
6. Set fish as default shell
7. Create wallpaper directories

After deploy:
1. Add wallpapers to `~/Pictures/Wallpapers/ultrawide/` and `~/Pictures/Wallpapers/4k/`
2. Reboot
3. On first login run: `~/.config/hypr/scripts/wallpaper-rotate.sh next`

---

A fully themed Hyprland setup inspired by HyDE, built for dual monitor:
- **DP-2**: 5120x1440 OLED ultrawide (no scaling)
- **DP-3**: 4K @ 1.25 scaling

## Features

- Waybar floating pill islands with wallbash color theming
- Rofi launcher (style 1 sideview)
- Wallbash — all colors derived from wallpaper automatically
- Maple Mono NF (terminal/bar) + CaskaydiaCove NF (GTK/UI)
- OLED burn-in protection via hypridle
- HDR + VRR tuned for both monitors
- Pyprland scratchpad terminal and file manager
- SDDM display manager
- Themed: hyprlock, wlogout, swaync, rofi, waybar

## Directory Structure

```
Rocko_DE/
├── waybar/          — bar config (single instance, all monitors), styles, scripts
├── rofi/            — launcher themes and launch script
├── hypr/            — hyprlock, hypridle, conf/, scripts/
├── swaync/          — notification center config + style
├── wlogout/         — logout menu layout + style
├── gtk/             — GTK3/4 settings
├── systemd/         — waybar user services
├── pypr/            — pyprland scratchpad config
├── nvim/            — neovim config
└── fastfetch/       — fastfetch config + avatar
```

## Install Locations

| File | Destination |
|------|-------------|
| waybar/config.jsonc | ~/.config/waybar/config.jsonc |
| waybar/style.css | ~/.config/waybar/style.css |
| waybar/colors.css | ~/.config/waybar/colors.css |
| waybar/scripts/* | ~/.config/waybar/scripts/ |
| rofi/theme.rasi | ~/.config/rofi/theme.rasi |
| rofi/themes/* | ~/.config/rofi/themes/ |
| rofi/rofilaunch.sh | ~/.config/hypr/scripts/rofilaunch.sh |
| hypr/hyprland.conf | ~/.config/hypr/hyprland.conf |
| hypr/hyprlock.conf | ~/.config/hypr/hyprlock.conf |
| hypr/hypridle.conf | ~/.config/hypr/hypridle.conf |
| hypr/scripts/* | ~/.config/hypr/scripts/ |
| hypr/conf/* | ~/.config/hypr/conf/ |
| swaync/config.json | ~/.config/swaync/config.json |
| swaync/style.css | ~/.config/swaync/style.css |
| wlogout/layout | ~/.config/wlogout/layout |
| wlogout/style.css | ~/.config/wlogout/style.css |
| gtk/gtk3-settings.ini | ~/.config/gtk-3.0/settings.ini |
| gtk/gtk4-settings.ini | ~/.config/gtk-4.0/settings.ini |
| systemd/* | ~/.config/systemd/user/ |
| pypr/config.toml | ~/.config/pypr/config.toml |
| nvim/* | ~/.config/nvim/ |
| fastfetch/config.jsonc | ~/.config/fastfetch/config.jsonc |
| fastfetch/avatar.png | ~/.config/fastfetch/avatar.png |

## Dependencies

**Official repos (pacman):**
```
hyprland hyprlock hypridle hyprpicker xdg-desktop-portal-hyprland
waybar swaync rofi-wayland wlogout swww
python-pywal imagemagick
kitty neovim yazi thunar
ttf-maple ttf-cascadia-code-nerd
ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono ttf-nerd-fonts-symbols-common
papirus-icon-theme
pipewire wireplumber pipewire-pulse pavucontrol playerctl
networkmanager network-manager-applet nm-connection-editor blueman
cliphist wl-clipboard grim slurp swappy
wl-color-picker brightnessctl polkit-gnome kdeconnect
nwg-look qt6ct kvantum fish starship sddm fastfetch
```

**AUR (paru):**
```
pyprland catppuccin-gtk-theme-mocha
```

## Notes

- Edit `waybar/scripts/weather.sh` to set your `LOCATION`
- Edit `hypr/scripts/wallpaper-rotate.sh` to set your wallpaper directories
- Wallbash colors auto-update on wallpaper change via `wallpaper-rotate.sh`
- Run `nwg-look` after first login to confirm GTK theme
