#!/bin/bash

# Make Alacritty the default terminal, wire Alt+t, refresh launchers.
# Does NOT remove Ghostty — that was a one-time migration / optional uninstall.

NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"
export DEBIAN_FRONTEND=noninteractive

echo "==> Ensuring Alacritty is installed and configured"
if [[ -f "$NOS_PATH/install/desktop/app-alacritty.sh" ]]; then
  # shellcheck disable=SC1091
  source "$NOS_PATH/install/desktop/app-alacritty.sh"
else
  sudo apt-get install -y alacritty || sudo apt install -y alacritty || true
fi

echo "==> Setting Alacritty as x-terminal-emulator default"
if [[ -x /usr/bin/alacritty ]]; then
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 60 2>/dev/null || true
  sudo update-alternatives --set x-terminal-emulator /usr/bin/alacritty 2>/dev/null || true
fi
if command -v alacritty >/dev/null; then
  xdg-mime default Alacritty.desktop x-scheme-handler/terminal 2>/dev/null || true
fi

echo "==> Binding Alt+t → new Alacritty window"
existing=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings 2>/dev/null || echo "@as []")
if ! echo "$existing" | grep -q 'custom2'; then
  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
    "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/']" \
    2>/dev/null || true
fi

gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "@as []" 2>/dev/null || true
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'New Alacritty Terminal' 2>/dev/null || true
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'alacritty' 2>/dev/null || true
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Alt>t' 2>/dev/null || true

echo "==> Refreshing NOS launchers + dock"
[[ -f "$NOS_PATH/applications/Nos.sh" ]] && source "$NOS_PATH/applications/Nos.sh"
[[ -f "$NOS_PATH/applications/Neovim.sh" ]] && source "$NOS_PATH/applications/Neovim.sh"
[[ -f "$NOS_PATH/applications/Docker.sh" ]] && source "$NOS_PATH/applications/Docker.sh"
[[ -f "$NOS_PATH/applications/About.sh" ]] && source "$NOS_PATH/applications/About.sh"
[[ -f "$NOS_PATH/applications/Activity.sh" ]] && source "$NOS_PATH/applications/Activity.sh"
[[ -f "$NOS_PATH/install/desktop/set-dock.sh" ]] && source "$NOS_PATH/install/desktop/set-dock.sh"

echo "Alacritty is default; Alt+t opens Alacritty."
