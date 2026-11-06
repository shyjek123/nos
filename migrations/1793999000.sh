#!/bin/bash

# Switch default terminal from Ghostty → Alacritty (Alt+t, launchers, dock)

echo "Migrating default terminal to Alacritty and removing Ghostty..."

# Refresh Alacritty NOS config + make it the system default
if [[ -f "$NOS_PATH/install/desktop/app-alacritty.sh" ]]; then
  # shellcheck disable=SC1090
  source "$NOS_PATH/install/desktop/app-alacritty.sh"
fi

# Remove Ghostty package/config if still present
if [[ -f "$NOS_PATH/uninstall/app-ghostty.sh" ]]; then
  # shellcheck disable=SC1090
  source "$NOS_PATH/uninstall/app-ghostty.sh"
fi

# Re-apply hotkeys so Alt+t opens Alacritty
if [[ -f "$NOS_PATH/install/desktop/set-gnome-hotkeys.sh" ]]; then
  # shellcheck disable=SC1090
  source "$NOS_PATH/install/desktop/set-gnome-hotkeys.sh"
fi

# Prefer Alacritty on the dock
if [[ -f "$NOS_PATH/install/desktop/set-dock.sh" ]]; then
  # shellcheck disable=SC1090
  source "$NOS_PATH/install/desktop/set-dock.sh"
fi

echo "Alacritty is now the default terminal (Alt+t). Ghostty removed if it was installed."
