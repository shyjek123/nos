#!/bin/bash

# One-time: remove Ghostty and switch default terminal to Alacritty (Alt+t, launchers, dock)

echo "One-time migration: remove Ghostty (if present) and set Alacritty as default..."

if [[ -f "$NOS_PATH/uninstall/app-ghostty.sh" ]]; then
  # shellcheck disable=SC1091
  source "$NOS_PATH/uninstall/app-ghostty.sh"
fi

if [[ -f "$NOS_PATH/install/desktop/ensure-alacritty-default.sh" ]]; then
  # shellcheck disable=SC1091
  source "$NOS_PATH/install/desktop/ensure-alacritty-default.sh"
fi
