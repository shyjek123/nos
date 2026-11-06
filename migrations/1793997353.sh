#!/bin/bash

# Attach new Alacritty windows to the stable default Zellij session.
if [ -f "$HOME/.config/alacritty/shared.toml" ]; then
  cp ~/.local/share/nos/configs/alacritty/shared.toml ~/.config/alacritty/shared.toml
fi
