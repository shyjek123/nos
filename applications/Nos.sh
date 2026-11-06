#!/bin/bash

cat <<EOF >~/.local/share/applications/Nos.desktop
[Desktop Entry]
Version=1.0
Name=NOS
Comment=NOS controls — themes, install, uninstall
Exec=alacritty --class Nos --title NOS -e bash -lc 'nos'
Terminal=false
Type=Application
Icon=/home/$USER/.local/share/nos/applications/icons/Nos.png
Categories=GTK;System;
StartupNotify=false
EOF
