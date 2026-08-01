#!/bin/bash

# Run desktop installers; one failure must not abort the rest of NOS
for installer in "$NOS_PATH"/install/desktop/*.sh; do
  echo "=> $(basename "$installer")"
  # shellcheck disable=SC1090
  if ! source "$installer"; then
    echo "WARNING: $(basename "$installer") failed — continuing install."
  fi
done

# Final safety net: stock Ubuntu GUI must still be present before reboot
if ! dpkg -l gdm3 2>/dev/null | grep -q '^ii' || ! dpkg -l gnome-shell 2>/dev/null | grep -q '^ii'; then
  echo "WARNING: Ubuntu desktop stack missing — restoring stock packages before reboot"
  sudo apt-get install -y ubuntu-desktop gdm3 gnome-shell ubuntu-session yelp ubuntu-wallpapers || true
fi
sudo systemctl set-default graphical.target 2>/dev/null || true
sudo systemctl enable gdm3 2>/dev/null || true

# Logout to pickup changes
gum confirm "Ready to reboot for all settings to take effect?" && sudo reboot || true
