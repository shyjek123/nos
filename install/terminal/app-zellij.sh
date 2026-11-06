#!/bin/bash

cd /tmp
wget -O zellij.tar.gz "https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz"
tar -xf zellij.tar.gz zellij
sudo install zellij /usr/local/bin
rm zellij.tar.gz zellij
cd -

mkdir -p ~/.config/zellij/themes ~/.local/bin
cp "${NOS_PATH:-$HOME/.local/share/nos}/configs/zellij.kdl" ~/.config/zellij/config.kdl
# Seed every theme so switching works offline
for theme_kdl in "${NOS_PATH:-$HOME/.local/share/nos}"/themes/*/zellij.kdl; do
  [[ -f "$theme_kdl" ]] || continue
  name=$(basename "$(dirname "$theme_kdl")")
  cp "$theme_kdl" ~/.config/zellij/themes/"$name".kdl
done

# GUI/hotkey launcher that always attaches to session "default"
chmod +x "${NOS_PATH:-$HOME/.local/share/nos}/bin/nos-zellij.sh"
ln -sfn "${NOS_PATH:-$HOME/.local/share/nos}/bin/nos-zellij.sh" "$HOME/.local/bin/nos-zellij"
