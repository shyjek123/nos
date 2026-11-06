#!/bin/bash

# Alacritty is the default terminal. shared.toml attaches new windows to Zellij.
sudo apt install -y alacritty
mkdir -p ~/.config/alacritty
cp "$NOS_PATH/configs/alacritty.toml" ~/.config/alacritty/alacritty.toml
cp "$NOS_PATH/configs/alacritty/shared.toml" ~/.config/alacritty/shared.toml
cp "$NOS_PATH/configs/alacritty/pane.toml" ~/.config/alacritty/pane.toml
cp "$NOS_PATH/configs/alacritty/btop.toml" ~/.config/alacritty/btop.toml
cp "$NOS_PATH/themes/c8-base/alacritty.toml" ~/.config/alacritty/theme.toml
cp "$NOS_PATH/configs/alacritty/fonts/CaskaydiaMono.toml" ~/.config/alacritty/font.toml
cp "$NOS_PATH/configs/alacritty/font-size.toml" ~/.config/alacritty/font-size.toml

# Migrate config format if needed
alacritty migrate 2>/dev/null || true
alacritty migrate -c ~/.config/alacritty/pane.toml 2>/dev/null || true
alacritty migrate -c ~/.config/alacritty/btop.toml 2>/dev/null || true

if [ -x /usr/bin/alacritty ]; then
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 50
  sudo update-alternatives --set x-terminal-emulator /usr/bin/alacritty
fi
