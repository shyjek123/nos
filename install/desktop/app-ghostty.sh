#!/bin/bash

# Ghostty — GPU-accelerated terminal (default for NOS)
# https://ghostty.org/
# Ubuntu 26.04+ ships Ghostty in universe; 24.04 needs the PPA.

sudo apt update -y
if ! apt-cache show ghostty &>/dev/null; then
  sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
  sudo apt update -y
fi
sudo apt install -y ghostty

mkdir -p ~/.config/ghostty/themes
cat >~/.config/ghostty/config <<'EOF'
theme = c8-base
font-family = CaskaydiaMono Nerd Font
font-size = 12
window-width = 120
window-height = 34
window-padding-x = 16
window-padding-y = 14
window-decoration = false
background-opacity = 0.85
background-opacity-cells = true
confirm-close-surface = false
mouse-scroll-multiplier = 1
keybind = f11=toggle_fullscreen
EOF

# Default C8 Base full ANSI colorscheme
cp "$NOS_PATH/themes/c8-base/ghostty" ~/.config/ghostty/themes/c8-base

source "$NOS_PATH/install/desktop/set-ghostty-default.sh"
