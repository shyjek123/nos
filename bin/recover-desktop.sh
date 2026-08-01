#!/bin/bash

# Recover a black / blank GNOME desktop after a NOS install.
# Safe to run from a TTY (Ctrl+Alt+F3) when the GUI is dead.
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
      echo "Disables NOS GNOME extensions, restores Ubuntu Dock, and sets a safe wallpaper."
      exit 0
      ;;
  esac
done

export NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"

echo "==> NOS desktop recovery"
echo "    User: $USER"
echo "    NOS:  $NOS_PATH"
echo

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

# Also strip them from the enabled-extensions list via dconf/gsettings when possible.
if command -v gsettings >/dev/null 2>&1; then
  current=$(gsettings get org.gnome.shell enabled-extensions 2>/dev/null || echo "@as []")
  cleaned="$current"
  for ext in "${NOS_EXTENSIONS[@]}"; do
    cleaned=$(python3 - "$cleaned" "$ext" <<'PY' 2>/dev/null || echo "$cleaned"
import ast, sys
raw, drop = sys.argv[1], sys.argv[2]
try:
    # gsettings prints e.g. ['a', 'b']
    items = ast.literal_eval(raw.replace("@as ", ""))
except Exception:
    print(raw)
    raise SystemExit
items = [i for i in items if i != drop]
print("[" + ", ".join(f"'{i}'" for i in items) + "]")
PY
)
  done
  gsettings set org.gnome.shell enabled-extensions "$cleaned" 2>/dev/null || true
fi

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

# If a known NOS wallpaper exists, point GNOME at a proper file:// URI.
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
echo "Recovery settings applied."
echo "Next: return to the login screen and sign in again."
echo "  • From TTY:  sudo systemctl restart gdm"
echo "  • Or reboot: sudo reboot"
echo
echo "After you're back on the desktop, re-enable extensions one at a time"
echo "in Extension Manager (start with everything except blur-my-shell)."

if [[ "$REBOOT" -eq 1 ]]; then
  echo
  echo "Rebooting now..."
  sudo reboot
fi
