# Rocko_DE — Hyprland Desktop Environment Config

## Quick Start — Fresh CachyOS Install

```bash
git clone https://github.com/ohnoibrokeit/Rocko_DE.git && cd Rocko_DE && bash deploy.sh
```

The deploy script will:
1. Install all required packages via pacman + paru
2. Deploy all configs to the correct locations
3. Enable systemd services
4. Set fonts system-wide
5. Set fish as default shell
6. Create wallpaper directories

After deploy:
1. Add wallpapers to `~/Pictures/Wallpapers/ultrawide/` and `~/Pictures/Wallpapers/4k/`
2. Reboot
3. On first login run: `~/.config/hypr/scripts/wallpaper-rotate.sh next`


A fully themed Hyprland setup inspired by HyDE, built for dual monitor:
- **DP-2**: 5120x1440 OLED ultrawide (no scaling)
- **DP-3**: 4K @ 1.25 scaling

## Features
- Waybar floating pill islands with wallbash color theming
- Rofi launcher (style 1 sideview) replacing wofi
- Wallbash — all colors derived from wallpaper automatically
- Maple Mono NF (terminal/bar) + CaskaydiaCove NF (GTK/UI)
- OLED burn-in protection via hypridle
- HDR + VRR tuned for both monitors
- Pyprland scratchpad terminal and file manager
- Themed: hyprlock, wlogout, swaync, rofi, waybar

## Directory Structure
```
Rocko_DE/
├── waybar/          — bar configs, styles, scripts
├── rofi/            — launcher themes and launch script
├── hypr/            — hyprlock, hypridle, scripts
├── swaync/          — notification center config + style
├── wlogout/         — logout menu layout + style
├── gtk/             — GTK3/4 settings, font apply script
├── systemd/         — waybar user services
└── pypr/            — pyprland scratchpad config
```

## Install Locations
| File | Destination |
|------|-------------|
| waybar/config.jsonc | ~/.config/waybar/config.jsonc |
| waybar/config-secondary.jsonc | ~/.config/waybar/config-secondary.jsonc |
| waybar/style.css | ~/.config/waybar/style.css |
| waybar/style-secondary.css | ~/.config/waybar/style-secondary.css |
| waybar/colors.css | ~/.config/waybar/colors.css |
| waybar/scripts/* | ~/.config/waybar/scripts/ |
| rofi/theme.rasi | ~/.config/rofi/theme.rasi |
| rofi/themes/* | ~/.config/rofi/themes/ |
| rofi/rofilaunch.sh | ~/.config/hypr/scripts/rofilaunch.sh |
| hypr/hyprlock.conf | ~/.config/hypr/hyprlock.conf |
| hypr/hypridle.conf | ~/.config/hypr/hypridle.conf |
| hypr/scripts/* | ~/.config/hypr/scripts/ |
| swaync/config.json | ~/.config/swaync/config.json |
| swaync/style.css | ~/.config/swaync/style.css |
| wlogout/layout | ~/.config/wlogout/layout |
| wlogout/style.css | ~/.config/wlogout/style.css |
| gtk/gtk3-settings.ini | ~/.config/gtk-3.0/settings.ini |
| gtk/gtk4-settings.ini | ~/.config/gtk-4.0/settings.ini |
| systemd/* | ~/.config/systemd/user/ |
| pypr/config.toml | ~/.config/pypr/config.toml |

## Dependencies
```
waybar rofi-wayland wlogout swaync hyprlock hypridle
pyprland swww python-pywal kitty yazi
ttf-maple nerd-fonts-cascadia-code imagemagick
```

## Notes
- Edit `weather.sh` to set your LOCATION
- Edit `wallpaper-rotate.sh` to set your wallpaper directories
- Run `gtk/apply-fonts.sh` once after installing fonts
- Wallbash colors auto-update on wallpaper change via `wallpaper-rotate.sh`
