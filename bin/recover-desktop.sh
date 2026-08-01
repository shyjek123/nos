#!/bin/bash

# Recover a missing / black GNOME desktop after a NOS install.
# Safe to run from a TTY when the GUI is dead.
#
# Usage:
#   bash ~/.local/share/nos/bin/recover-desktop.sh
#   bash ~/.local/share/nos/bin/recover-desktop.sh --reboot

set -euo pipefail

REBOOT=0
for arg in "$@"; do
  case "$arg" in
    --reboot|-r) REBOOT=1 ;;
    -h|--help)
      echo "Usage: $0 [--reboot]"
      echo "Reinstalls the Ubuntu GUI if missing, disables NOS extensions,"
      echo "restores Ubuntu Dock, and sets a safe wallpaper."
      exit 0
      ;;
  esac
done

export NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"
export DEBIAN_FRONTEND=noninteractive

echo "==> NOS desktop recovery"
echo "    User: $USER"
echo "    NOS:  $NOS_PATH"
echo

pkg_installed() {
  dpkg -l "$1" 2>/dev/null | grep -q '^ii'
}

echo "==> Checking display manager / GNOME shell packages"
NEED_DESKTOP=0
for pkg in gdm3 gnome-shell ubuntu-session yelp; do
  if ! pkg_installed "$pkg"; then
    echo "    MISSING: $pkg"
    NEED_DESKTOP=1
  else
    echo "    ok: $pkg"
  fi
done

if [[ "$NEED_DESKTOP" -eq 1 ]] || ! pkg_installed ubuntu-desktop; then
  echo "==> Reinstalling Ubuntu desktop (this is why you only see a TTY)"
  sudo apt-get update
  sudo apt-get install -y ubuntu-desktop gdm3 gnome-shell ubuntu-session yelp
fi

echo "==> Ensuring graphical boot target"
sudo systemctl set-default graphical.target
sudo systemctl enable gdm3 2>/dev/null || sudo systemctl enable gdm 2>/dev/null || true
sudo apt-mark manual gdm3 gnome-shell ubuntu-session ubuntu-desktop yelp 2>/dev/null || true

# Prefer a live user session bus when available (GUI still half-alive).
if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
  for bus in "/run/user/$(id -u)/bus" "/run/user/$(id -u)/dbus/user_bus_socket"; do
    if [[ -S "$bus" ]]; then
      export DBUS_SESSION_BUS_ADDRESS="unix:path=$bus"
      break
    fi
  done
fi

echo "==> Disabling user-installed GNOME extensions (common black-screen cause)"
gsettings set org.gnome.shell disable-user-extensions true 2>/dev/null || true

NOS_EXTENSIONS=(
  "tactile@lundal.io"
  "just-perfection-desktop@just-perfection"
  "blur-my-shell@aunetx"
  "space-bar@luchrioh"
  "undecorate@sun.wxg@gmail.com"
  "tophat@fflewddur.github.io"
  "AlphabeticalAppGrid@stuarthayhurst"
)

for ext in "${NOS_EXTENSIONS[@]}"; do
  if command -v gnome-extensions >/dev/null 2>&1; then
    gnome-extensions disable "$ext" 2>/dev/null || true
  fi
done

echo "==> Restoring Ubuntu Dock / app indicators"
for ext in \
  "ubuntu-dock@ubuntu.com" \
  "ubuntu-appindicators@ubuntu.com" \
  "tiling-assistant@ubuntu.com" \
  "ding@rastersoft.com"; do
  if command -v gnome-extensions >/dev/null 2>&1; then
    gnome-extensions enable "$ext" 2>/dev/null || true
  fi
done

echo "==> Setting a safe solid background (avoids broken wallpaper URI)"
gsettings set org.gnome.desktop.background picture-options 'none' 2>/dev/null || true
gsettings set org.gnome.desktop.background primary-color '#1e1e1e' 2>/dev/null || true
gsettings set org.gnome.desktop.background color-shading-type 'solid' 2>/dev/null || true

SAFE_BG=""
shopt -s nullglob
candidates=(
  "$NOS_PATH/themes/tokyo-night/background.jpg"
  "$NOS_PATH/themes/catppuccin/background.png"
  "$NOS_PATH/themes/velocity/background.jpg"
  "$HOME/.local/share/backgrounds/"*.jpg
  "$HOME/.local/share/backgrounds/"*.png
)
shopt -u nullglob
for candidate in "${candidates[@]}"; do
  if [[ -f "$candidate" ]]; then
    SAFE_BG="$candidate"
    break
  fi
done

if [[ -n "$SAFE_BG" ]]; then
  URI="file://$SAFE_BG"
  gsettings set org.gnome.desktop.background picture-uri "$URI" 2>/dev/null || true
  gsettings set org.gnome.desktop.background picture-uri-dark "$URI" 2>/dev/null || true
  gsettings set org.gnome.desktop.background picture-options 'zoom' 2>/dev/null || true
  echo "    Wallpaper: $SAFE_BG"
fi

echo "==> Re-enabling screen lock defaults"
gsettings set org.gnome.desktop.screensaver lock-enabled true 2>/dev/null || true
gsettings set org.gnome.desktop.session idle-delay 300 2>/dev/null || true

echo
echo "Recovery complete."
echo "Start the login screen with:"
echo "  sudo systemctl start gdm3"
echo "Or reboot:"
echo "  sudo reboot"

if [[ "$REBOOT" -eq 1 ]]; then
  echo
  echo "Rebooting now..."
  sudo reboot
fi
