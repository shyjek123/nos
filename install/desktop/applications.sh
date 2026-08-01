#!/bin/bash

# Remove leftover Omakub launchers (broken icons / wrong Exec)
rm -f "$HOME/.local/share/applications/Omakub.desktop"

# Core NOS desktop launchers only (web apps are opt-in via select-web-apps).
shopt -s nullglob
for name in Nos Neovim Docker About Activity; do
  script="$NOS_PATH/applications/${name}.sh"
  if [[ -f "$script" ]]; then
    # shellcheck disable=SC1090
    source "$script"
  fi
done
