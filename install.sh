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

nos_disable_sleep() {
  # Prevent blank/lock/sleep for the whole install (display going black mid-run)
  gsettings set org.gnome.desktop.screensaver lock-enabled false 2>/dev/null || true
  gsettings set org.gnome.desktop.screensaver idle-activation-enabled false 2>/dev/null || true
  gsettings set org.gnome.desktop.session idle-delay 0 2>/dev/null || true
  gsettings set org.gnome.settings-daemon.plugins.power idle-dim false 2>/dev/null || true
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' 2>/dev/null || true
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing' 2>/dev/null || true
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0 2>/dev/null || true
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0 2>/dev/null || true
  # X11 fallbacks (no-op on pure Wayland)
  xset s off 2>/dev/null || true
  xset -dpms 2>/dev/null || true
}

nos_restore_sleep() {
  gsettings set org.gnome.desktop.screensaver lock-enabled true 2>/dev/null || true
  gsettings set org.gnome.desktop.screensaver idle-activation-enabled true 2>/dev/null || true
  gsettings set org.gnome.desktop.session idle-delay 300 2>/dev/null || true
  gsettings set org.gnome.settings-daemon.plugins.power idle-dim true 2>/dev/null || true
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'suspend' 2>/dev/null || true
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend' 2>/dev/null || true
  xset s on 2>/dev/null || true
  xset +dpms 2>/dev/null || true
}

# Desktop software and tweaks will only be installed if we're running Gnome
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  nos_disable_sleep
  # Always restore power settings even if a later step fails
  trap 'nos_restore_sleep; echo "Nos installation failed! You can retry by running: source \"$NOS_PATH/install.sh\""' ERR

  echo "Installing terminal and desktop tools..."

  # Install terminal tools
  source "$NOS_PATH/install/terminal.sh"

  # Install desktop tools and tweaks
  source "$NOS_PATH/install/desktop.sh"

  nos_restore_sleep
  # Keep the original ERR trap message after successful desktop path
  trap 'echo "Nos installation failed! You can retry by running: source \"$NOS_PATH/install.sh\""' ERR
else
  echo "Only installing terminal tools..."
  source "$NOS_PATH/install/terminal.sh"
fi
