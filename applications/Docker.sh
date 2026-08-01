#!/bin/bash

cat <<EOF >~/.local/share/applications/Docker.desktop
[Desktop Entry]
Version=1.0
Name=Docker
Comment=Manage Docker containers with LazyDocker
Exec=ghostty --class=Docker -o window-padding-x=30 -o window-padding-y=30 -e lazydocker
Terminal=false
Type=Application
Icon=/home/$USER/.local/share/nos/applications/icons/Docker.png
Categories=GTK;
StartupNotify=false
EOF
