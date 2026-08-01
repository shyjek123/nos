#!/bin/bash

COMPUTER_MAKER=$(sudo dmidecode -t system | grep 'Manufacturer:' | awk '{print $2}')
SCREEN_RESOLUTION=$(xrandr 2>/dev/null | grep '*+' | awk '{print $1}')

if [ "$COMPUTER_MAKER" == "Framework" ] && [ "$SCREEN_RESOLUTION" == "2256x1504" ]; then
	gsettings set org.gnome.desktop.interface text-scaling-factor 0.8
	gsettings set org.gnome.desktop.interface cursor-size 16
	if [ -f ~/.config/alacritty/alacritty.toml ]; then
		sed -i "s/size = 9/size = 7/g" ~/.config/alacritty/alacritty.toml
	fi
fi
