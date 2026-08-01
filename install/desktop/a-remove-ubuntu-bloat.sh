#!/bin/bash

# Remove unused consumer apps only (email, games, office, etc.).
# Never touch the Ubuntu desktop stack — GDM, GNOME Shell, session,
# help browser, stock wallpapers, branding, and ubuntu-desktop stay installed
# as the stock fallback if NOS theming/extensions misbehave.

export DEBIAN_FRONTEND=noninteractive

echo "Removing unused Ubuntu apps (desktop stack kept intact)..."

# Hard refuse list: desktop / session / fallback assets. Never purge these.
PROTECTED_PKGS_REGEX='^(yelp|gdm3|gnome-shell|gnome-shell-common|ubuntu-session|ubuntu-desktop|ubuntu-desktop-minimal|ubuntu-settings|ubuntu-wallpapers|ubuntu-wallpapers-.*|brand-ubuntu|gnome-initial-setup|gnome-user-docs|ubuntu-docs|nautilus|xorg|xwayland|yaru-theme-.*|plymouth-theme-.*)$'

# Games only
BLOAT_GAMES=(
  aisleriot
  gnome-mahjongg
  gnome-mines
  gnome-sudoku
  gnome-tetravex
  gnome-taquin
  lightsoff
  quadrapassel
  swell-foop
  iagno
  five-or-more
  four-in-a-row
  hitori
  gnome-chess
  gnome-robots
  tali
)

# Unused apps the user does not need (NOT desktop infrastructure)
BLOAT_APPS=(
  thunderbird
  thunderbird-gnome-support
  rhythmbox
  rhythmbox-plugins
  totem
  totem-plugins
  cheese
  shotwell
  shotwell-common
  remmina
  remmina-common
  remmina-plugin-rdp
  remmina-plugin-vnc
  remmina-plugin-secret
  transmission-gtk
  transmission-common
  example-content
  libreoffice-writer
  libreoffice-calc
  libreoffice-impress
  libreoffice-draw
  libreoffice-math
  libreoffice-gnome
  libreoffice-common
  libreoffice-core
)

is_protected() {
  [[ "$1" =~ $PROTECTED_PKGS_REGEX ]]
}

purge_list() {
  local pkg
  for pkg in "$@"; do
    if is_protected "$pkg"; then
      echo "WARNING: refusing to purge protected package: $pkg"
      continue
    fi
    if [[ "$pkg" == *"*"* ]]; then
      echo "WARNING: refusing glob purge: $pkg"
      continue
    fi
    if dpkg -l "$pkg" 2>/dev/null | grep -q '^ii'; then
      # Purge only this package; never run autoremove (can strip the desktop).
      sudo apt-get purge -y -o APT::Get::AutomaticRemove=false "$pkg" 2>/dev/null || true
    fi
  done
}

purge_list "${BLOAT_GAMES[@]}"
purge_list "${BLOAT_APPS[@]}"

# Ensure the stock Ubuntu desktop fallback is present and pinned manual
# so a later autoremove elsewhere cannot delete the GUI.
echo "Ensuring Ubuntu stock desktop fallback is installed..."
sudo apt-get install -y --no-remove \
  ubuntu-desktop \
  ubuntu-desktop-minimal \
  gdm3 \
  gnome-shell \
  ubuntu-session \
  yelp \
  ubuntu-wallpapers \
  ubuntu-docs \
  brand-ubuntu \
  2>/dev/null || sudo apt-get install -y \
  ubuntu-desktop \
  gdm3 \
  gnome-shell \
  ubuntu-session \
  yelp \
  ubuntu-wallpapers \
  || true

sudo apt-mark manual \
  ubuntu-desktop \
  ubuntu-desktop-minimal \
  gdm3 \
  gnome-shell \
  gnome-shell-common \
  ubuntu-session \
  ubuntu-settings \
  yelp \
  nautilus \
  xorg \
  ubuntu-wallpapers \
  ubuntu-docs \
  brand-ubuntu \
  2>/dev/null || true

sudo systemctl set-default graphical.target 2>/dev/null || true
sudo systemctl enable gdm3 2>/dev/null || sudo systemctl enable gdm 2>/dev/null || true

# Intentionally NO apt autoremove here. Autoremove after purging recommends
# can delete the desktop metapackage's other packages and leave a TTY-only boot.

echo "Unused-app cleanup complete (Ubuntu desktop fallback preserved)."
