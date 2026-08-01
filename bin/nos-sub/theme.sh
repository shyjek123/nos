#!/bin/bash

THEME_NAMES=("Artura" "C8 Z06" "Velocity" "Tokyo Night" "Catppuccin" "Nord" "Everforest" "Gruvbox" "Kanagawa" "Ristretto" "Rose Pine" "Matte Black" "Osaka Jade")
THEME=$(gum choose "${THEME_NAMES[@]}" "<< Back" --header "Choose your theme" --height 15 | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

if [ -n "$THEME" ] && [ "$THEME" != "<<-back" ]; then
  source "$NOS_PATH/themes/switch-theme.sh" "$THEME"
fi

source "$NOS_PATH/bin/nos-sub/menu.sh"
