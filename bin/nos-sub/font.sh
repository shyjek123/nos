#!/bin/bash

set_font() {
	local font_name=$1
	local url=$2
	local file_type=$3
	local file_name="${font_name/ Nerd Font/}"

	if ! $(fc-list | grep -i "$font_name" >/dev/null); then
		cd /tmp
		wget -O "$file_name.zip" "$url"
		unzip "$file_name.zip" -d "$file_name"
		cp "$file_name"/*."$file_type" ~/.local/share/fonts
		rm -rf "$file_name.zip" "$file_name"
		fc-cache
		cd -
		clear
		source $NOS_PATH/ascii.sh
	fi

	gsettings set org.gnome.desktop.interface monospace-font-name "$font_name 10"
	if [[ -d "$HOME/.config/alacritty" ]]; then
		cp "$NOS_PATH/configs/alacritty/fonts/$file_name.toml" ~/.config/alacritty/font.toml
	fi
	if [[ -f "$HOME/.config/ghostty/config" ]]; then
		sed -i "s/^font-family = .*/font-family = $font_name/" ~/.config/ghostty/config
		if ! grep -q '^font-family = ' ~/.config/ghostty/config; then
			echo "font-family = $font_name" >>~/.config/ghostty/config
		fi
	fi
	if [[ -f "$HOME/.config/Code/User/settings.json" ]]; then
		sed -i "s/\"editor.fontFamily\": \".*\"/\"editor.fontFamily\": \"$font_name\"/g" ~/.config/Code/User/settings.json
	fi
}

if [ "$#" -gt 1 ]; then
	choice=${!#}
else
	choice=$(gum choose "Cascadia Mono" "Fira Mono" "JetBrains Mono" "Meslo" "> Change size" "<< Back" --height 8 --header "Choose your programming font")
fi

case $choice in
"Cascadia Mono")
	set_font "CaskaydiaMono Nerd Font" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip" "ttf"
	;;
"Fira Mono")
	set_font "FiraMono Nerd Font" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraMono.zip" "otf"
	;;
"JetBrains Mono")
	set_font "JetBrainsMono Nerd Font" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" "ttf"
	;;
"Meslo")
	set_font "MesloLGS Nerd Font" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip" "ttf"
	;;
"> Change size")
	source $NOS_PATH/bin/nos-sub/font-size.sh
	exit
	;;
esac

source $NOS_PATH/bin/nos-sub/menu.sh
