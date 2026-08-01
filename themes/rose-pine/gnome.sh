#!/bin/bash

NOS_THEME_COLOR="red"
NOS_THEME_BACKGROUND="rose-pine/background.jpg"
source $NOS_PATH/themes/set-gnome-theme.sh
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
