#!/bin/bash

# NOS desktop stays in dark mode (shell, GTK, and libadwaita).
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
gsettings set org.gnome.shell.ubuntu color-scheme 'prefer-dark' 2>/dev/null || true

nos_enable_gtk_dark() {
  local file="$1"
  mkdir -p "$(dirname "$file")"
  if [[ ! -f "$file" ]]; then
    printf '[Settings]\ngtk-application-prefer-dark-theme=1\n' >"$file"
    return
  fi
  if grep -q '^gtk-application-prefer-dark-theme=' "$file"; then
    sed -i 's/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=1/' "$file"
  elif grep -q '^\[Settings\]' "$file"; then
    sed -i '/^\[Settings\]/a gtk-application-prefer-dark-theme=1' "$file"
  else
    printf '\n[Settings]\ngtk-application-prefer-dark-theme=1\n' >>"$file"
  fi
}
nos_enable_gtk_dark "$HOME/.config/gtk-3.0/settings.ini"
nos_enable_gtk_dark "$HOME/.config/gtk-4.0/settings.ini"

# Center new windows in the middle of the screen
gsettings set org.gnome.mutter center-new-windows true

# Set Cascadia Mono as the default monospace font
gsettings set org.gnome.desktop.interface monospace-font-name 'CaskaydiaMono Nerd Font 12'

# Reveal week numbers in the Gnome calendar
gsettings set org.gnome.desktop.calendar show-weekdate true

# Turn off ambient sensors for setting screen brightness (they rarely work well!)
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false
