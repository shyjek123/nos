#!/bin/bash

# Configure the bash shell using nos defaults
[ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
cp ~/.local/share/nos/configs/bashrc ~/.bashrc

# Load the PATH for use later in the installers
source ~/.local/share/nos/defaults/bash/shell

[ -f ~/.inputrc ] && mv ~/.inputrc ~/.inputrc.bak
# Configure the inputrc using nos defaults
cp ~/.local/share/nos/configs/inputrc ~/.inputrc
