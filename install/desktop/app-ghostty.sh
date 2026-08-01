#!/bin/bash

# Ghostty — GPU-accelerated terminal (default for NOS)
# https://ghostty.org/
sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
sudo apt update -y
sudo apt install -y ghostty

mkdir -p ~/.config/ghostty/themes
cat >~/.config/ghostty/config <<'EOF'
theme = c8-z06
font-family = CaskaydiaMono Nerd Font
font-size = 10
window-padding-x = 16
window-padding-y = 14
window-decoration = false
background-opacity = 0.98
confirm-close-surface = false
keybind = f11=toggle_fullscreen
EOF

# Default C8 Z06 full ANSI colorscheme
cp "$NOS_PATH/themes/c8-z06/ghostty" ~/.config/ghostty/themes/c8-z06

source "$NOS_PATH/install/desktop/set-ghostty-default.sh"
