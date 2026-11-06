#!/bin/bash

# Uninstall Ghostty and point NOS at Alacritty
sudo apt remove -y ghostty || true
sudo add-apt-repository -y --remove ppa:mkasberg/ghostty-ubuntu 2>/dev/null || true
rm -rf ~/.config/ghostty

# Drop Ghostty from update-alternatives if present
if command -v update-alternatives >/dev/null && [ -x /usr/bin/alacritty ]; then
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 50 2>/dev/null || true
  sudo update-alternatives --set x-terminal-emulator /usr/bin/alacritty 2>/dev/null || true
fi

# Refresh NOS launchers + Alt+t hotkey to Alacritty
if [[ -n "${NOS_PATH:-}" ]]; then
  [[ -f "$NOS_PATH/applications/Nos.sh" ]] && source "$NOS_PATH/applications/Nos.sh"
  [[ -f "$NOS_PATH/applications/Neovim.sh" ]] && source "$NOS_PATH/applications/Neovim.sh"
  [[ -f "$NOS_PATH/applications/Docker.sh" ]] && source "$NOS_PATH/applications/Docker.sh"
fi

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'New Alacritty Terminal' 2>/dev/null || true
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'alacritty' 2>/dev/null || true
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Alt>t' 2>/dev/null || true
