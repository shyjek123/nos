#!/usr/bin/env sh

# Make Ghostty the default terminal emulator when available
if [ -x /usr/bin/ghostty ]; then
	sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/ghostty 50
	sudo update-alternatives --set x-terminal-emulator /usr/bin/ghostty
fi
