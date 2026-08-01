#!/bin/bash

# Prefer a real icon file — Icon=nvim often resolves to a missing/generic icon
ICON="$HOME/.local/share/nos/applications/icons/Neovim.png"
if [[ ! -f "$ICON" ]]; then
  # Fall back to Activity-style branding if no dedicated Neovim icon yet
  if [[ -f /usr/local/share/icons/hicolor/128x128/apps/nvim.png ]]; then
    ICON=/usr/local/share/icons/hicolor/128x128/apps/nvim.png
  elif [[ -f "$HOME/.local/share/nos/applications/icons/Nos.png" ]]; then
    ICON="$HOME/.local/share/nos/applications/icons/Nos.png"
  else
    ICON=nvim
  fi
fi

cat <<EOF >~/.local/share/applications/Neovim.desktop
[Desktop Entry]
Version=1.0
Name=Neovim
Comment=Edit text files
Exec=ghostty --class=Neovim -o window-padding-x=30 -o window-padding-y=30 -e nvim %F
Terminal=false
Type=Application
Icon=$ICON
Categories=Utilities;TextEditor;
StartupNotify=false
EOF
