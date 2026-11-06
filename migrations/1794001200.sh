#!/bin/bash

# One-time: ensure Alacritty defaults / Alt+t (does not touch Ghostty again)
if [[ -f "$NOS_PATH/install/desktop/ensure-alacritty-default.sh" ]]; then
  # shellcheck disable=SC1091
  source "$NOS_PATH/install/desktop/ensure-alacritty-default.sh"
fi
