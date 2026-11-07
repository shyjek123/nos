#!/bin/bash

# Configure the bash shell using nos defaults (scripts stay bash).
[ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
cp ~/.local/share/nos/configs/bashrc ~/.bashrc

# Interactive terminal is zsh: syntax highlighting, suggestions, colored ls.
sudo apt install -y zsh zsh-syntax-highlighting zsh-autosuggestions
if [[ -f ~/.zshrc && ! -f ~/.zshrc.bak ]]; then
  mv ~/.zshrc ~/.zshrc.bak
fi
cp ~/.local/share/nos/configs/zshrc ~/.zshrc

# Load the PATH for use later in the installers
source ~/.local/share/nos/defaults/bash/shell

[ -f ~/.inputrc ] && mv ~/.inputrc ~/.inputrc.bak
# Configure the inputrc using nos defaults
cp ~/.local/share/nos/configs/inputrc ~/.inputrc
