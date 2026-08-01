#!/bin/bash

sudo apt install -y gnome-shell-extension-manager gir1.2-gtop-2.0 gir1.2-clutter-1.0
pipx install gnome-extensions-cli --system-site-packages

# Turn off default Ubuntu extensions (ignore if not installed)
gnome-extensions disable tiling-assistant@ubuntu.com 2>/dev/null || true
gnome-extensions disable ubuntu-appindicators@ubuntu.com 2>/dev/null || true
gnome-extensions disable ubuntu-dock@ubuntu.com 2>/dev/null || true
gnome-extensions disable ding@rastersoft.com 2>/dev/null || true

# Pause to assure user is ready to accept confirmations (must not abort install under set -e)
if ! gum confirm "To install Gnome extensions, you need to accept some confirmations. Ready?"; then
  echo "Skipping Gnome extension install/config."
  return 0 2>/dev/null || true
fi

EXTENSIONS=(
  tactile@lundal.io
  just-perfection-desktop@just-perfection
  blur-my-shell@aunetx
  space-bar@luchrioh
  undecorate@sun.wxg@gmail.com
  tophat@fflewddur.github.io
  AlphabeticalAppGrid@stuarthayhurst
)

# Install new extensions
for ext in "${EXTENSIONS[@]}"; do
  gext install "$ext" || echo "WARNING: gext install failed for $ext"
done

# Compile gsettings schemas in order to be able to set them
for schema in \
  "$HOME/.local/share/gnome-shell/extensions/tactile@lundal.io/schemas/org.gnome.shell.extensions.tactile.gschema.xml" \
  "$HOME/.local/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas/org.gnome.shell.extensions.just-perfection.gschema.xml" \
  "$HOME/.local/share/gnome-shell/extensions/blur-my-shell@aunetx/schemas/org.gnome.shell.extensions.blur-my-shell.gschema.xml" \
  "$HOME/.local/share/gnome-shell/extensions/space-bar@luchrioh/schemas/org.gnome.shell.extensions.space-bar.gschema.xml" \
  "$HOME/.local/share/gnome-shell/extensions/tophat@fflewddur.github.io/schemas/org.gnome.shell.extensions.tophat.gschema.xml" \
  "$HOME/.local/share/gnome-shell/extensions/AlphabeticalAppGrid@stuarthayhurst/schemas/org.gnome.shell.extensions.AlphabeticalAppGrid.gschema.xml"; do
  if [[ -f "$schema" ]]; then
    sudo cp "$schema" /usr/share/glib-2.0/schemas/
  else
    echo "WARNING: Missing extension schema: $schema"
  fi
done
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

# Safe Mode / tweak tools set this true and leave only stock workspace dots
gsettings set org.gnome.shell disable-user-extensions false

# gext install does not always enable — force-enable via CLI + gsettings
for ext in "${EXTENSIONS[@]}"; do
  gnome-extensions enable "$ext" 2>/dev/null || true
done

# Persist enabled/disabled lists (survives until next shell load)
gsettings set org.gnome.shell enabled-extensions \
  "['tactile@lundal.io', 'just-perfection-desktop@just-perfection', 'blur-my-shell@aunetx', 'space-bar@luchrioh', 'undecorate@sun.wxg@gmail.com', 'tophat@fflewddur.github.io', 'AlphabeticalAppGrid@stuarthayhurst']"
gsettings set org.gnome.shell disabled-extensions \
  "['ubuntu-dock@ubuntu.com', 'ding@rastersoft.com', 'tiling-assistant@ubuntu.com', 'ubuntu-appindicators@ubuntu.com']"

# Configure Tactile
gsettings set org.gnome.shell.extensions.tactile col-0 1
gsettings set org.gnome.shell.extensions.tactile col-1 2
gsettings set org.gnome.shell.extensions.tactile col-2 1
gsettings set org.gnome.shell.extensions.tactile col-3 0
gsettings set org.gnome.shell.extensions.tactile row-0 1
gsettings set org.gnome.shell.extensions.tactile row-1 1
gsettings set org.gnome.shell.extensions.tactile gap-size 32

# Configure Just Perfection (copied from Omakub)
gsettings set org.gnome.shell.extensions.just-perfection animation 2
gsettings set org.gnome.shell.extensions.just-perfection dash-app-running true
gsettings set org.gnome.shell.extensions.just-perfection workspace true
gsettings set org.gnome.shell.extensions.just-perfection workspace-popup false

# Configure Blur My Shell (copied from Omakub)
gsettings set org.gnome.shell.extensions.blur-my-shell.appfolder blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.lockscreen blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.screenshot blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.window-list blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.panel blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.overview blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.overview pipeline 'pipeline_default'
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock brightness 0.6
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock sigma 30
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock static-blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 0

# Configure Space Bar — Omakub base + numbered static workspaces in the top bar
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 6
gsettings set org.gnome.shell.extensions.space-bar.behavior smart-workspace-names false
gsettings set org.gnome.shell.extensions.space-bar.shortcuts enable-activate-workspace-shortcuts false
gsettings set org.gnome.shell.extensions.space-bar.shortcuts enable-move-to-workspace-shortcuts true
gsettings set org.gnome.shell.extensions.space-bar.shortcuts open-menu "@as []"
gsettings set org.gnome.shell.extensions.space-bar.behavior indicator-style 'workspaces-bar'
gsettings set org.gnome.shell.extensions.space-bar.behavior position 'left'
gsettings set org.gnome.shell.extensions.space-bar.behavior position-index 0
gsettings set org.gnome.shell.extensions.space-bar.behavior show-empty-workspaces true
gsettings set org.gnome.shell.extensions.space-bar.behavior always-show-numbers true
gsettings set org.gnome.shell.extensions.space-bar.behavior system-workspace-indicator false
gsettings set org.gnome.shell.extensions.space-bar.behavior enable-custom-label true
gsettings set org.gnome.shell.extensions.space-bar.behavior custom-label-unnamed '{{number}}'
gsettings set org.gnome.shell.extensions.space-bar.behavior custom-label-named '{{number}}'

# Configure TopHat
gsettings set org.gnome.shell.extensions.tophat show-icons false
gsettings set org.gnome.shell.extensions.tophat show-cpu false
gsettings set org.gnome.shell.extensions.tophat show-disk false
gsettings set org.gnome.shell.extensions.tophat show-mem false
gsettings set org.gnome.shell.extensions.tophat show-fs false
gsettings set org.gnome.shell.extensions.tophat network-usage-unit bits

# Configure AlphabeticalAppGrid
gsettings set org.gnome.shell.extensions.alphabetical-app-grid folder-order-position 'end'
