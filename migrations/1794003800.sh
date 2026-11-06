#!/bin/bash

# Stop Alacritty blink-crash: heal Zellij config + resilient default-session launcher
echo "Repairing Zellij default-session startup..."
chmod +x "$NOS_PATH/bin/nos-zellij.sh" 2>/dev/null || true
if [[ -f "$NOS_PATH/install/desktop/app-alacritty.sh" ]]; then
  # shellcheck disable=SC1091
  source "$NOS_PATH/install/desktop/app-alacritty.sh"
fi
