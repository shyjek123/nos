#!/bin/bash

set -e

ascii_art='
═══════════════════════════════════════════════════════

███╗   ██╗███████╗██╗  ██╗████████╗
████╗  ██║██╔════╝╚██╗██╔╝╚══██╔══╝
██╔██╗ ██║█████╗   ╚███╔╝    ██║
██║╚██╗██║██╔══╝   ██╔██╗    ██║
██║ ╚████║███████╗██╔╝ ██╗   ██║
╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝   ╚═╝

                  O P E R A T I N G   S Y S T E M

═══════════════════════════════════════════════════════
'

echo -e "$ascii_art"
echo "=> NOS is for fresh Ubuntu 24.04+ installations only!"
echo -e "\nBegin installation (or abort with ctrl+c)..."

sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

echo "Cloning NOS..."
rm -rf ~/.local/share/nos
git clone https://github.com/shyjek123/nos.git ~/.local/share/nos >/dev/null

if [[ $NOS_REF != "master" ]]; then
  cd ~/.local/share/nos
  git fetch origin "${NOS_REF:-stable}" && git checkout "${NOS_REF:-stable}"
  cd -
fi

echo "Installation starting ..."
source ~/.local/share/nos/install.sh
