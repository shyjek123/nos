#!/bin/bash

# Purge stock Ubuntu desktop bloat NOS does not need.
# Runs early in the desktop install loop (a-*.sh).
# Safe to re-run; missing packages are ignored.

export DEBIAN_FRONTEND=noninteractive

echo "Removing Ubuntu default bloat..."

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

# Stock apps replaced by NOS tooling / unused for cybersec work
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
  yelp
  gnome-user-docs
  ubuntu-docs
  example-content
  libreoffice*
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

# Branding / welcome / tour
BLOAT_MISC=(
  gnome-initial-setup
  gnome-tour
  brand-ubuntu
  ubuntu-wallpapers
  ubuntu-wallpapers-noble
)

purge_list() {
  local pkg
  for pkg in "$@"; do
    # Skip globs that apt can't resolve as a single name when quoted wrongly —
    # libreoffice* is handled via apt pattern below.
    if [[ "$pkg" == *"*"* ]]; then
      sudo apt-get purge -y "$pkg" 2>/dev/null || true
    else
      if dpkg -l "$pkg" 2>/dev/null | grep -q '^ii'; then
        sudo apt-get purge -y "$pkg" 2>/dev/null || true
      fi
    fi
  done
}

purge_list "${BLOAT_GAMES[@]}"
purge_list "${BLOAT_APPS[@]}"
purge_list "${BLOAT_TELEMETRY[@]}"
purge_list "${BLOAT_SNAP_UI[@]}"
purge_list "${BLOAT_MISC[@]}"

# Catch remaining LibreOffice packages by pattern
sudo apt-get purge -y 'libreoffice*' 2>/dev/null || true

# Autoremove orphans left behind
sudo apt-get autoremove -y --purge
sudo apt-get autoclean -y

echo "Ubuntu bloat removal complete."
