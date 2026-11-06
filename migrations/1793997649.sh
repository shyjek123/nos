#!/bin/bash

# Alacritty replaces Ghostty as the default terminal.
NOS_ROOT="${NOS_PATH:-$HOME/.local/share/nos}"

if [ -x /usr/bin/alacritty ]; then
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 50
  sudo update-alternatives --set x-terminal-emulator /usr/bin/alacritty
fi

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'New Alacritty Window' 2>/dev/null || true
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'alacritty' 2>/dev/null || true

for launcher in Neovim Docker Nos; do
  if [ -f "$NOS_ROOT/applications/${launcher}.sh" ]; then
    # shellcheck disable=SC1090
    source "$NOS_ROOT/applications/${launcher}.sh"
  fi
done

favs=$(gsettings get org.gnome.shell favorite-apps 2>/dev/null || true)
if [[ "$favs" == *"com.mitchellh.ghostty.desktop"* ]]; then
  gsettings set org.gnome.shell favorite-apps "${favs//com.mitchellh.ghostty.desktop/Alacritty.desktop}" 2>/dev/null || true
fi
