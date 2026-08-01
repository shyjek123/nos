#!/bin/bash

# exit on any error returned
set -e

# chance to try reinstalling
trap 'echo "Nos installation failed! You can retry by running: source ~/.local/share/nos/install.sh"' ERR

# check distro name and version and abort if incompatible
source ~/.local/share/nos/install/check-version.sh

#ask for app choices
echo "Get ready to make a few choices..."
source ~/.local/share/nos/install/terminal/required/app-gum.sh >/dev/null
source ~/.local/share/nos/isntall/first-run-choices.sh
source ~/.local/share/nos/isntall/identification.sh

# desktop software and tweaks will only be installed if running Gnome
if [[ "$XDG_CURRECT_DESKTOP" == *"GNOME"* ]]; then
  #ensure computer doesnt go to sleep or lock during install
  gsettings set org.gnome.desktop.screensaver lock-enabled false
  gsettings set org.gnome.desktop.session idle-delay 0

  echo "Installing terminal and desktop tools..."

  #install terminal tools
  source ~/.local/share/nos/install/terminal.sh

  # install desktop tools and tweaks
  source ~/.local/share/nos/install/desktop.sh

  # Revert to normal idle and lock settings
  gsettings set org.gnome.desktop.screensaver lock-enabled true
  gsettings set org.gnome.desktop.session idle-delay 300
else
  echo "Only installing terminal tools..."
  source ~/.local/share/nos/install/terminal.sh
fi

