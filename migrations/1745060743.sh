#!/bin/bash

cp ~/.local/share/nos/configs/alacritty/shared.toml ~/.config/alacritty/shared.toml
cp ~/.local/share/nos/configs/alacritty/pane.toml ~/.config/alacritty/pane.toml
cp ~/.local/share/nos/configs/alacritty/btop.toml ~/.config/alacritty/btop.toml
cp ~/.local/share/nos/configs/alacritty.toml ~/.config/alacritty/alacritty.toml

source $NOS_PATH/applications/About.sh
source $NOS_PATH/applications/Activity.sh
source $NOS_PATH/applications/Neovim.sh
source $NOS_PATH/applications/Docker.sh
source $NOS_PATH/applications/Nos.sh

alacritty migrate 2>/dev/null || true
alacritty migrate -c ~/.config/alacritty/pane.toml 2>/dev/null || true
alacritty migrate -c ~/.config/alacritty/btop.toml 2>/dev/null || true
