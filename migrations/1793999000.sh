#!/bin/bash

# Switch default terminal from Ghostty → Alacritty (Alt+t, launchers, dock)

echo "Migrating default terminal to Alacritty and removing Ghostty..."
if [[ -f "$NOS_PATH/install/desktop/ensure-alacritty-default.sh" ]]; then
  # shellcheck disable=SC1091
  source "$NOS_PATH/install/desktop/ensure-alacritty-default.sh"
fi
