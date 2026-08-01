#!/bin/bash

# Uninstall Ghostty and fall back to Alacritty for hotkeys / launchers
sudo apt remove -y ghostty || true
sudo add-apt-repository -y --remove ppa:mkasberg/ghostty-ubuntu 2>/dev/null || true
rm -rf ~/.config/ghostty

# Point NOS launchers back at Alacritty if available
if command -v alacritty >/dev/null; then
  for desktop in Nos Neovim Docker; do
    f="$HOME/.local/share/applications/${desktop}.desktop"
    [[ -f "$f" ]] || continue
    sed -i \
      -e 's|Exec=ghostty --class=[^ ]* -o window-padding-x=30 -o window-padding-y=30 -e|Exec=alacritty -e|' \
      -e 's|Exec=ghostty|Exec=alacritty|' \
      "$f" 2>/dev/null || true
  done
  # Alt+t terminal hotkey (custom2 in set-gnome-hotkeys.sh)
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'alacritty' 2>/dev/null || true
fi
