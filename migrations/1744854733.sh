#!/bin/bash

# Historical: briefly preferred Ghostty. Current default is Alacritty again.
if [ -x /usr/bin/alacritty ] && [ -f "$NOS_PATH/install/desktop/set-alacritty-default.sh" ]; then
	source "$NOS_PATH/install/desktop/set-alacritty-default.sh"
fi

nautilus -q
