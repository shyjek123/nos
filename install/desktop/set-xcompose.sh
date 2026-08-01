#!/bin/bash

sudo apt-get install -y gettext-base >/dev/null
envsubst <"$NOS_PATH/configs/xcompose" >~/.XCompose
ibus restart 2>/dev/null || true
gsettings set org.gnome.desktop.input-sources xkb-options "['compose:caps']"
