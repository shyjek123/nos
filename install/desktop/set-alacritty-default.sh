#!/usr/bin/env sh

# Make Alacritty the default terminal emulator when available
if [ -x /usr/bin/alacritty ]; then
	sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 50
	sudo update-alternatives --set x-terminal-emulator /usr/bin/alacritty
fi
