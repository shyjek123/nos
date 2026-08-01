#!/bin/bash

cp ~/.local/share/nos/configs/alacritty/btop.toml ~/.config/alacritty/btop.toml

# Only attempt to set configuration if btop is not already set
if [ ! -f "$HOME/.config/btop/btop.conf" ]; then
  # Use NOS btop config
  mkdir -p ~/.config/btop/themes
  cp ~/.local/share/nos/configs/btop.conf ~/.config/btop/btop.conf
fi

# Set the theme for btop
THEME_NAMES=("Tokyo Night" "Catppuccin" "Nord" "Everforest" "Gruvbox" "Kanagawa" "Rose Pine")
THEME=$(gum choose "${THEME_NAMES[@]}" ">> Skip" --header "Choose your current theme" --height 10 | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

if [ -n "$THEME" ] && [ "$THEME" != ">>-skip" ]; then
  if [ -f "$NOS_PATH/themes/$THEME/btop.theme" ]; then
    cp $NOS_PATH/themes/$THEME/btop.theme ~/.config/btop/themes/$THEME.theme
    sed -i "s/color_theme = \".*\"/color_theme = \"$THEME\"/g" ~/.config/btop/btop.conf
  else
    sed -i "s/color_theme = \".*\"/color_theme = \"Default\"/g" ~/.config/btop/btop.conf
  fi
fi

