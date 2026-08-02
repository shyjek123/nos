#!/bin/bash

# One-shot repair for top bar (Space Bar), theme/wallpaper, and launchers.
# Usage: source ~/.local/share/nos/install/desktop/fix-gnome-desktop.sh

NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"

echo "==> Enabling NOS GNOME extensions (Space Bar = numbered workspaces)"
# Stock dots appear when this is true — Space Bar never becomes ACTIVE
gsettings set org.gnome.shell disable-user-extensions false

gnome-extensions disable ubuntu-dock@ubuntu.com 2>/dev/null || true
gnome-extensions disable ding@rastersoft.com 2>/dev/null || true
gnome-extensions disable tiling-assistant@ubuntu.com 2>/dev/null || true

for ext in \
  tactile@lundal.io \
  just-perfection-desktop@just-perfection \
  blur-my-shell@aunetx \
  space-bar@luchrioh \
  undecorate@sun.wxg@gmail.com \
  tophat@fflewddur.github.io \
  AlphabeticalAppGrid@stuarthayhurst; do
  if [[ -d "$HOME/.local/share/gnome-shell/extensions/$ext" ]]; then
    gnome-extensions enable "$ext" 2>/dev/null && echo "  enabled $ext" || echo "  WARNING: could not enable $ext"
  else
    echo "  missing $ext — re-run: source \"$NOS_PATH/install/desktop/set-gnome-extensions.sh\""
  fi
done

gsettings set org.gnome.shell enabled-extensions \
  "['tactile@lundal.io', 'just-perfection-desktop@just-perfection', 'blur-my-shell@aunetx', 'space-bar@luchrioh', 'undecorate@sun.wxg@gmail.com', 'tophat@fflewddur.github.io', 'AlphabeticalAppGrid@stuarthayhurst']"
gsettings set org.gnome.shell disabled-extensions \
  "['ubuntu-dock@ubuntu.com', 'ding@rastersoft.com', 'tiling-assistant@ubuntu.com', 'ubuntu-appindicators@ubuntu.com']"

# Top bar / workspaces — Omakub Just Perfection + Space Bar, with numbered static desks
gsettings set org.gnome.shell.extensions.just-perfection animation 2 2>/dev/null || true
gsettings set org.gnome.shell.extensions.just-perfection dash-app-running true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.just-perfection workspace true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.just-perfection workspace-popup false 2>/dev/null || true

gsettings set org.gnome.mutter dynamic-workspaces false 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences num-workspaces 6 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.behavior smart-workspace-names false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.shortcuts enable-activate-workspace-shortcuts false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.shortcuts enable-move-to-workspace-shortcuts true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.shortcuts open-menu "@as []" 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.behavior indicator-style 'workspaces-bar' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.behavior position 'left' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.behavior position-index 0 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.behavior show-empty-workspaces true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.behavior always-show-numbers true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.behavior system-workspace-indicator false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.behavior enable-custom-label true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.behavior custom-label-unnamed '{{number}}' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.space-bar.behavior custom-label-named '{{number}}' 2>/dev/null || true

# Super+1..6 workspace switch (from Omakub hotkeys)
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']" 2>/dev/null || true
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']" 2>/dev/null || true
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']" 2>/dev/null || true
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']" 2>/dev/null || true
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>5']" 2>/dev/null || true
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<Super>6']" 2>/dev/null || true

echo "==> Applying C8 Base theme (Omakub-style single wallpaper + full ANSI terminal)"
rm -f "$HOME/.local/share/backgrounds/"*slideshow*.xml 2>/dev/null || true
# shellcheck disable=SC1091
source "$NOS_PATH/themes/switch-theme.sh" c8-base

echo "==> Refreshing launchers / removing Omakub leftovers"
# shellcheck disable=SC1091
source "$NOS_PATH/install/desktop/applications.sh"
source "$NOS_PATH/install/desktop/set-dock.sh" 2>/dev/null || true

echo
echo "Done. Press Alt+F2, type 'r', Enter (or log out/in) so GNOME reloads extensions."
echo "Default theme: C8 Base (red). Switch to Artura anytime: nos → Theme."
