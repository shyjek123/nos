#!/bin/bash

cat <<EOF >~/.local/share/applications/Neovim.desktop
[Desktop Entry]
Version=1.0
Name=Neovim
Comment=Edit text files
Exec=ghostty --class=Neovim -o window-padding-x=30 -o window-padding-y=30 -e nvim %F
Terminal=false
Type=Application
Icon=nvim
Categories=Utilities;TextEditor;
StartupNotify=false
EOF
