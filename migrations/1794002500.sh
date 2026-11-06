#!/bin/bash

# Alacritty Ghostty-parity themes/fonts, git-aware prompt
echo "Refreshing Alacritty + bash prompt..."

if [[ -f "$NOS_PATH/install/desktop/app-alacritty.sh" ]]; then
  # shellcheck disable=SC1091
  source "$NOS_PATH/install/desktop/app-alacritty.sh"
fi

# Prompt lives under NOS defaults (sourced by ~/.bashrc → defaults/bash/rc)
# Force a clean shell tip:
echo "Open a new Alacritty window (Alt+t). Prompt shows cwd + git."
