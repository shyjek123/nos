#!/bin/bash

# Ghostty — GPU-accelerated terminal (default for NOS)
# https://ghostty.org/
sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
sudo apt update -y
sudo apt install -y ghostty

mkdir -p ~/.config/ghostty
cat >~/.config/ghostty/config <<'EOF'
config-file = ?theme
font-family = CaskaydiaMono Nerd Font
font-size = 10
window-padding-x = 16
window-padding-y = 14
window-decoration = false
background-opacity = 0.98
confirm-close-surface = false
keybind = f11=toggle_fullscreen
EOF

# Default Velocity car theme colors
cp "$NOS_PATH/themes/velocity/ghostty" ~/.config/ghostty/theme

source "$NOS_PATH/install/desktop/set-ghostty-default.sh"
