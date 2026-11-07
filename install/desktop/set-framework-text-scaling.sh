#!/bin/bash

# Framework laptops with high-DPI panels — Wayland-safe resolution detection
# (Ubuntu 26.04 GNOME is Wayland-only; xrandr is X11/XWayland fallback only).

COMPUTER_MAKER=$(sudo dmidecode -t system | grep 'Manufacturer:' | awk '{print $2}')

nos_detect_resolution() {
  # GNOME 48+ display tool
  if command -v gdctl >/dev/null 2>&1; then
    gdctl show 2>/dev/null | grep -oE '[0-9]+x[0-9]+' | head -1
    return 0
  fi
  # X11 / XWayland fallback
  if command -v xrandr >/dev/null 2>&1; then
    xrandr 2>/dev/null | grep '*+' | awk '{print $1}' | head -1
    return 0
  fi
  return 1
}

SCREEN_RESOLUTION=$(nos_detect_resolution || true)

# Known Framework 13 / 16 panel modes that need slightly smaller UI chrome
case "$SCREEN_RESOLUTION" in
  2256x1504|2880x1920|3000x2000|2940x1838)
    FRAMEWORK_HIDPI=1
    ;;
  *)
    FRAMEWORK_HIDPI=0
    ;;
esac

if [ "$COMPUTER_MAKER" == "Framework" ] && [ "$FRAMEWORK_HIDPI" = "1" ]; then
  gsettings set org.gnome.desktop.interface text-scaling-factor 0.8
  gsettings set org.gnome.desktop.interface cursor-size 16
  # HiDPI panels already scale the UI up, so step the medium terminal font down one notch.
  if [ -f ~/.config/alacritty/font-size.toml ]; then
    sed -i "s/^size = 12$/size = 10/" ~/.config/alacritty/font-size.toml
  fi
  if [ -f ~/.config/ghostty/config ]; then
    sed -i "s/^font-size = 12$/font-size = 10/" ~/.config/ghostty/config
  fi
fi
