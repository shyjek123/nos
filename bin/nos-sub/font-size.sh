#!/bin/bash

choice=$(gum choose {7..14} "<< Back" --height 11 --header "Choose your terminal font size")

if [[ $choice =~ ^[0-9]+$ ]]; then
	if [[ -f "$HOME/.config/alacritty/font-size.toml" ]]; then
		sed -i "s/^size = .*$/size = $choice/g" ~/.config/alacritty/font-size.toml
	fi
	if [[ -f "$HOME/.config/ghostty/config" ]]; then
		sed -i "s/^font-size = .*/font-size = $choice/" ~/.config/ghostty/config
		if ! grep -q '^font-size = ' ~/.config/ghostty/config; then
			echo "font-size = $choice" >>~/.config/ghostty/config
		fi
	fi
	source $NOS_PATH/bin/nos-sub/font-size.sh
else
	source $NOS_PATH/bin/nos-sub/font.sh
fi
