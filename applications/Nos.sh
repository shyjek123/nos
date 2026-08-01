#!/bin/bash

cat <<EOF >~/.local/share/applications/Nos.desktop
[Desktop Entry]
Version=1.0
Name=NOS
Comment=NOS controls — themes, install, uninstall
Exec=ghostty --class=Nos -o window-padding-x=30 -o window-padding-y=30 -e bash -lc 'nos'
Terminal=false
Type=Application
Icon=/home/$USER/.local/share/nos/applications/icons/Nos.png
Categories=GTK;System;
StartupNotify=false
EOF
