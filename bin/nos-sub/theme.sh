#!/bin/bash

THEME_NAMES=("Velocity" "Tokyo Night" "Catppuccin" "Nord" "Everforest" "Gruvbox" "Kanagawa" "Ristretto" "Rose Pine" "Matte Black" "Osaka Jade")
THEME=$(gum choose "${THEME_NAMES[@]}" "<< Back" "Exit" --header "Choose your theme" --height 14 | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

if [[ -z "$THEME" || "$THEME" == "exit" ]]; then
  return 0 2>/dev/null || exit 0
fi

if [ -n "$THEME" ] && [ "$THEME" != "<<-back" ]; then
  source "$NOS_PATH/themes/switch-theme.sh" "$THEME"
fi

# shellcheck disable=SC1091
source "$NOS_PATH/bin/nos-sub/return.sh"
