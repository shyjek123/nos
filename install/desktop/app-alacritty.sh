#!/bin/bash

# Alacritty is kept as a lightweight terminal for About / Activity panes.
# Ghostty remains the default interactive terminal.
sudo apt install -y alacritty
mkdir -p ~/.config/alacritty
cp "$NOS_PATH/configs/alacritty.toml" ~/.config/alacritty/alacritty.toml
cp "$NOS_PATH/configs/alacritty/shared.toml" ~/.config/alacritty/shared.toml
cp "$NOS_PATH/configs/alacritty/pane.toml" ~/.config/alacritty/pane.toml
cp "$NOS_PATH/configs/alacritty/btop.toml" ~/.config/alacritty/btop.toml
cp "$NOS_PATH/themes/c8-z06/alacritty.toml" ~/.config/alacritty/theme.toml
cp "$NOS_PATH/configs/alacritty/fonts/CaskaydiaMono.toml" ~/.config/alacritty/font.toml
cp "$NOS_PATH/configs/alacritty/font-size.toml" ~/.config/alacritty/font-size.toml

# Migrate config format if needed
alacritty migrate 2>/dev/null || true
alacritty migrate -c ~/.config/alacritty/pane.toml 2>/dev/null || true
alacritty migrate -c ~/.config/alacritty/btop.toml 2>/dev/null || true
