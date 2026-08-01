#!/bin/bash

# Purge stock Ubuntu desktop bloat NOS does not need.
# Runs early in the desktop install loop (a-*.sh).
# Safe to re-run; missing packages are ignored.
#
# IMPORTANT: Never purge hard Depends of ubuntu-desktop /
# ubuntu-desktop-minimal (e.g. yelp, gdm3, gnome-shell). Doing so
# removes the desktop metapackage; the following autoremove can then
# uninstall GDM and leave the machine booting to a TTY only.

export DEBIAN_FRONTEND=noninteractive

echo "Removing Ubuntu default bloat..."

# Packages that must never be purged by this script (desktop boot stack).
PROTECTED_PKGS_REGEX='^(yelp|gdm3|gnome-shell|gnome-shell-common|ubuntu-session|ubuntu-desktop|ubuntu-desktop-minimal|ubuntu-settings|nautilus|xorg|xwayland)$'

# Games
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

# Stock apps replaced by NOS tooling / unused for cybersec work.
# Do NOT list yelp / gnome-shell / gdm3 here — they are desktop Depends.
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
  gnome-calendar
  gnome-contacts
  gnome-maps
  gnome-weather
  gnome-clocks
  gnome-music
  gnome-photos
  deja-dup
  simple-scan
  baobab
  gnome-user-docs
  ubuntu-docs
  example-content
  libreoffice-common
  libreoffice-core
  libreoffice-writer
  libreoffice-calc
  libreoffice-impress
  libreoffice-draw
  libreoffice-math
  libreoffice-gnome
  hunspell-en-us
)

# Telemetry / crash reporting / adware-ish defaults
BLOAT_TELEMETRY=(
  apport
  apport-gtk
  apport-symptoms
  whoopsie
  whoopsie-preferences
  ubuntu-report
  popularity-contest
  kerneloops
)

# Snap store UI clutter (keep snapd + gnome-software for Flatpak)
BLOAT_SNAP_UI=(
  snap-store
  ubuntu-software
  gnome-software-plugin-snap
)

# Branding / welcome / tour (recommends only — safe to drop)
BLOAT_MISC=(
  gnome-initial-setup
  gnome-tour
  brand-ubuntu
  ubuntu-wallpapers
  ubuntu-wallpapers-noble
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
      # Never pass broad globs that could match protected packages.
      echo "WARNING: refusing glob purge: $pkg"
      continue
    fi
    if dpkg -l "$pkg" 2>/dev/null | grep -q '^ii'; then
      sudo apt-get purge -y "$pkg" 2>/dev/null || true
    fi
  done
}

purge_list "${BLOAT_GAMES[@]}"
purge_list "${BLOAT_APPS[@]}"
purge_list "${BLOAT_TELEMETRY[@]}"
purge_list "${BLOAT_SNAP_UI[@]}"
purge_list "${BLOAT_MISC[@]}"

# LibreOffice only — explicit names, not a bare '*' that apt could mis-handle
sudo apt-get purge -y \
  'libreoffice-common' \
  'libreoffice-core' \
  'libreoffice-writer' \
  'libreoffice-calc' \
  'libreoffice-impress' \
  'libreoffice-draw' \
  'libreoffice-math' \
  'libreoffice-gnome' \
  'libreoffice-style-*' \
  2>/dev/null || true

# Autoremove orphans, but never allow removal of the graphical stack.
# apt-get autoremove will refuse to remove manually marked packages; mark
# the display manager stack manual before cleaning.
sudo apt-mark manual \
  gdm3 \
  gnome-shell \
  gnome-shell-common \
  ubuntu-session \
  ubuntu-desktop \
  ubuntu-desktop-minimal \
  yelp \
  nautilus \
  xorg \
  2>/dev/null || true

sudo apt-get autoremove -y --purge \
  -o APT::Get::AutomaticRemove=true \
  2>/dev/null || true
sudo apt-get autoclean -y

# If the desktop metapackage vanished somehow, put the GUI back immediately.
if ! dpkg -l gdm3 2>/dev/null | grep -q '^ii' || ! dpkg -l gnome-shell 2>/dev/null | grep -q '^ii'; then
  echo "WARNING: display stack missing after bloat removal — reinstalling ubuntu-desktop"
  sudo apt-get install -y ubuntu-desktop gdm3 gnome-shell ubuntu-session yelp || true
fi

sudo systemctl set-default graphical.target 2>/dev/null || true
sudo systemctl enable gdm3 2>/dev/null || sudo systemctl enable gdm 2>/dev/null || true

echo "Ubuntu bloat removal complete."
