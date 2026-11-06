#!/bin/bash

# Fix Alacritty blink-and-close: Zellij not on GUI PATH + safer launcher
echo "Fixing Alacritty startup (Zellij wrapper)..."
chmod +x "$NOS_PATH/bin/nos-zellij.sh" 2>/dev/null || true
if [[ -f "$NOS_PATH/install/desktop/app-alacritty.sh" ]]; then
  # shellcheck disable=SC1091
  source "$NOS_PATH/install/desktop/app-alacritty.sh"
fi
