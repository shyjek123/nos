#!/bin/bash

# Exit clears the screen; Ghostty → Alacritty default + Alt+t
if [[ -f "$NOS_PATH/install/desktop/ensure-alacritty-default.sh" ]]; then
  # shellcheck disable=SC1091
  source "$NOS_PATH/install/desktop/ensure-alacritty-default.sh"
fi
