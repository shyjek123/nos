#!/bin/bash

# Ghostty is the default terminal (was Alacritty); skip re-asserting Alacritty.
if [ -x /usr/bin/ghostty ] && [ -f "$NOS_PATH/install/desktop/set-ghostty-default.sh" ]; then
	source "$NOS_PATH/install/desktop/set-ghostty-default.sh"
fi

nautilus -q
