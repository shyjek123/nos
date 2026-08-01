#!/bin/bash

sudo add-apt-repository universe -y
sudo add-apt-repository ppa:agornostal/ulauncher -y
sudo apt update
sudo apt install ulauncher -y

# Start ulauncher to have it populate config before we overwrite
mkdir -p ~/.config/autostart/
mkdir -p ~/.config/ulauncher/
cp "$NOS_PATH/configs/ulauncher.desktop" ~/.config/autostart/ulauncher.desktop
gtk-launch ulauncher.desktop >/dev/null 2>&1 || true
sleep 2 # ensure enough time for ulauncher to set defaults
cp "$NOS_PATH/configs/ulauncher.json" ~/.config/ulauncher/settings.json
