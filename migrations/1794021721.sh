#!/bin/bash

# Desktop dark mode, and a medium starting terminal (120x34 at font size 12).

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
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

FONT_SIZE="$HOME/.config/alacritty/font-size.toml"
if [[ -f "$FONT_SIZE" ]] && grep -q '^size = 9$' "$FONT_SIZE"; then
  sed -i 's/^size = 9$/size = 12/' "$FONT_SIZE"
fi

SHARED="$HOME/.config/alacritty/shared.toml"
if [[ -f "$SHARED" ]] && ! grep -q '^dimensions\.columns' "$SHARED"; then
  if grep -q '^\[window\]' "$SHARED"; then
    sed -i '/^\[window\]/a dimensions.columns = 120\ndimensions.lines = 34' "$SHARED"
  else
    printf '\n[window]\ndimensions.columns = 120\ndimensions.lines = 34\n' >>"$SHARED"
  fi
fi

GHOSTTY="$HOME/.config/ghostty/config"
if [[ -f "$GHOSTTY" ]]; then
  if grep -qE '^font-size = (9|10)$' "$GHOSTTY"; then
    sed -i -E 's/^font-size = (9|10)$/font-size = 12/' "$GHOSTTY"
  fi
  grep -q '^window-width[[:space:]]*=' "$GHOSTTY" || echo 'window-width = 120' >>"$GHOSTTY"
  grep -q '^window-height[[:space:]]*=' "$GHOSTTY" || echo 'window-height = 34' >>"$GHOSTTY"
fi
