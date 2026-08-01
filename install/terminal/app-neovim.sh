#!/bin/bash

cd /tmp
wget -O nvim.tar.gz "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"
tar -xf nvim.tar.gz
sudo install nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
sudo cp -R nvim-linux-x86_64/lib /usr/local/
sudo cp -R nvim-linux-x86_64/share /usr/local/
rm -rf nvim-linux-x86_64 nvim.tar.gz
cd -

sudo apt install -y luarocks tree-sitter-cli

# Only attempt to set configuration if Neovim has never been run
if [ ! -d "$HOME/.config/nvim" ]; then
  # Use LazyVim
  git clone https://github.com/shyjek123/Nvim_Config ~/.config/Nvim_Config
  mv ~/.config/Nvim_Config/nvim ~/.config
  # Remove the .git folder, so you can add it to your own repo later
  rm -rf ~/.config/Nvim_Config

  # Turn off animated scrolling (best-effort; config layout may vary)
  if [[ -f ~/.local/share/nos/configs/neovim/snacks-animated-scrolling-off.lua ]]; then
    mkdir -p ~/.config/nvim/lua/plugins
    cp ~/.local/share/nos/configs/neovim/snacks-animated-scrolling-off.lua ~/.config/nvim/lua/plugins/
  fi
fi

# Replace desktop launcher with one running inside Ghostty
if [[ -d ~/.local/share/applications ]]; then
  sudo rm -rf /usr/share/applications/nvim.desktop
  sudo rm -rf /usr/local/share/applications/nvim.desktop
  source ~/.local/share/nos/applications/Neovim.sh
fi
