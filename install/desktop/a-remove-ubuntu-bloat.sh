#!/bin/bash

# Purge stock Ubuntu desktop bloat NOS does not need.
# Runs early in the desktop install loop (a-*.sh).
# Safe to re-run; missing packages are ignored.
#
# Kept on purpose: the NOS wallpaper, snapd and installed snaps, and LibreOffice.

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
  gnome-characters
  gnome-font-viewer
  gnome-logs
  gnome-calculator
  gnome-sound-recorder
  gnome-todo
  usb-creator-gtk
  pitivi
  gnome-games
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

# Branding / welcome / tour.
# ubuntu-wallpapers is the stock image pack. NOS applies its own background later.
# snapd is not listed here, so installed snap packages stay.
BLOAT_MISC=(
  gnome-initial-setup
  gnome-tour
  brand-ubuntu
  ubuntu-wallpapers
  ubuntu-wallpapers-noble
  ubuntu-wallpapers-resolute
)

purge_list() {
  local pkg
  for pkg in "$@"; do
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
purge_list "${BLOAT_MISC[@]}"

# Autoremove orphans left behind
sudo apt-get autoremove -y --purge
sudo apt-get autoclean -y

echo "Ubuntu bloat removal complete."
