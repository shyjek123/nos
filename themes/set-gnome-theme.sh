#!/bin/bash

# Same flow as Omakub for GNOME, plus NOS terminal colors that track the theme.
NOS_ROOT="${NOS_PATH:-$HOME/.local/share/nos}"
THEME_DIR_NAME=$(dirname "$NOS_THEME_BACKGROUND")
THEME_DIR="$NOS_ROOT/themes/$THEME_DIR_NAME"

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
gsettings set org.gnome.desktop.interface gtk-theme "Yaru-$NOS_THEME_COLOR-dark"
gsettings set org.gnome.desktop.interface icon-theme "Yaru-$NOS_THEME_COLOR"
gsettings set org.gnome.desktop.interface accent-color "$NOS_THEME_COLOR" 2>/dev/null || true

BACKGROUND_ORG_PATH="$NOS_ROOT/themes/$NOS_THEME_BACKGROUND"
BACKGROUND_DEST_DIR="$HOME/.local/share/backgrounds"
BACKGROUND_DEST_PATH="$BACKGROUND_DEST_DIR/$(echo $NOS_THEME_BACKGROUND | tr '/' '-')"

if [ ! -d "$BACKGROUND_DEST_DIR" ]; then mkdir -p "$BACKGROUND_DEST_DIR"; fi

[ ! -f $BACKGROUND_DEST_PATH ] && cp $BACKGROUND_ORG_PATH $BACKGROUND_DEST_PATH
gsettings set org.gnome.desktop.background picture-uri $BACKGROUND_DEST_PATH
gsettings set org.gnome.desktop.background picture-uri-dark $BACKGROUND_DEST_PATH
gsettings set org.gnome.desktop.background picture-options 'zoom'

# --- Terminals: full ANSI 16-color palette (Omakub-style) ---
# Every colorized CLI (ls/eza/git/grep/bat --theme=ansi/…) maps through these slots.

# Ghostty — official `theme = name` loader (themes live in ~/.config/ghostty/themes/)
if [[ -f "$THEME_DIR/ghostty" ]]; then
  mkdir -p "$HOME/.config/ghostty/themes"
  cp "$THEME_DIR/ghostty" "$HOME/.config/ghostty/themes/$THEME_DIR_NAME"
  cp "$THEME_DIR/ghostty" "$HOME/.config/ghostty/theme"

  if [[ ! -f "$HOME/.config/ghostty/config" ]]; then
    cat >"$HOME/.config/ghostty/config" <<EOF
theme = ${THEME_DIR_NAME}
font-family = CaskaydiaMono Nerd Font
font-size = 10
window-padding-x = 16
window-padding-y = 14
window-decoration = false
background-opacity = 0.98
confirm-close-surface = false
keybind = f11=toggle_fullscreen
EOF
  else
    sed -i '/^config-file[[:space:]]*=/d' "$HOME/.config/ghostty/config"
    if grep -q '^theme[[:space:]]*=' "$HOME/.config/ghostty/config"; then
      sed -i "s|^theme[[:space:]]*=.*|theme = ${THEME_DIR_NAME}|" "$HOME/.config/ghostty/config"
    else
      sed -i "1i theme = ${THEME_DIR_NAME}" "$HOME/.config/ghostty/config"
    fi
  fi
fi

# Alacritty (About / Activity) — imports theme.toml like Omakub
if [[ -f "$THEME_DIR/alacritty.toml" ]]; then
  mkdir -p "$HOME/.config/alacritty"
  cp "$THEME_DIR/alacritty.toml" "$HOME/.config/alacritty/theme.toml"
fi
