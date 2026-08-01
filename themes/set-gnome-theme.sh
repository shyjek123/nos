#!/bin/bash

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
gsettings set org.gnome.desktop.interface gtk-theme "Yaru-$NOS_THEME_COLOR-dark"
gsettings set org.gnome.desktop.interface icon-theme "Yaru-$NOS_THEME_COLOR"
gsettings set org.gnome.desktop.interface accent-color "$NOS_THEME_COLOR" 2>/dev/null || true

BACKGROUND_ORG_PATH="$HOME/.local/share/nos/themes/$NOS_THEME_BACKGROUND"
BACKGROUND_DEST_DIR="$HOME/.local/share/backgrounds"
BACKGROUND_DEST_PATH="$BACKGROUND_DEST_DIR/$(echo $NOS_THEME_BACKGROUND | tr '/' '-')"

# Prefer rotating slideshow when themes/<name>/wallpapers/ has images
THEME_DIR=$(dirname "$NOS_THEME_BACKGROUND")
WALLPAPERS_DIR="$HOME/.local/share/nos/themes/$THEME_DIR/wallpapers"

if [ -d "$WALLPAPERS_DIR" ] && find "$WALLPAPERS_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | grep -q .; then
  bash "$HOME/.local/share/nos/bin/nos-set-wallpaper-slideshow.sh" "$WALLPAPERS_DIR"
else
  if [ ! -d "$BACKGROUND_DEST_DIR" ]; then mkdir -p "$BACKGROUND_DEST_DIR"; fi
  [ ! -f "$BACKGROUND_DEST_PATH" ] && cp "$BACKGROUND_ORG_PATH" "$BACKGROUND_DEST_PATH"
  gsettings set org.gnome.desktop.background picture-uri "$BACKGROUND_DEST_PATH"
  gsettings set org.gnome.desktop.background picture-uri-dark "$BACKGROUND_DEST_PATH"
  gsettings set org.gnome.desktop.background picture-options 'zoom'
fi
