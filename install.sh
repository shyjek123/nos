#!/bin/bash

# exit on any error returned
set -e

export NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"

# chance to try reinstalling
trap 'echo "Nos installation failed! You can retry by running: source \"$NOS_PATH/install.sh\""' ERR

# check distro name and version and abort if incompatible
source "$NOS_PATH/install/check-version.sh"

# Ask for app choices
echo "Get ready to make a few choices..."
source "$NOS_PATH/install/terminal/required/app-gum.sh" >/dev/null
source "$NOS_PATH/install/first-run-choices.sh"
source "$NOS_PATH/install/identification.sh"

# Desktop software and tweaks will only be installed if we're running Gnome
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  # Ensure computer doesn't go to sleep or lock while installing
  gsettings set org.gnome.desktop.screensaver lock-enabled false
  gsettings set org.gnome.desktop.session idle-delay 0

  echo "Installing terminal and desktop tools..."

  # Install terminal tools
  source "$NOS_PATH/install/terminal.sh"

  # Install desktop tools and tweaks
  source "$NOS_PATH/install/desktop.sh"

  # Revert to normal idle and lock settings
  gsettings set org.gnome.desktop.screensaver lock-enabled true
  gsettings set org.gnome.desktop.session idle-delay 300
else
  echo "Only installing terminal tools..."
  source "$NOS_PATH/install/terminal.sh"
fi

