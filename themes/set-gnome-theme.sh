#!/bin/bash

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
gsettings set org.gnome.desktop.interface gtk-theme "Yaru-$NOS_THEME_COLOR-dark"
gsettings set org.gnome.desktop.interface icon-theme "Yaru-$NOS_THEME_COLOR"
gsettings set org.gnome.desktop.interface accent-color "$NOS_THEME_COLOR" 2>/dev/null || true

BACKGROUND_ORG_PATH="$HOME/.local/share/nos/themes/$NOS_THEME_BACKGROUND"
BACKGROUND_DEST_DIR="$HOME/.local/share/backgrounds"
BACKGROUND_DEST_PATH="$BACKGROUND_DEST_DIR/$(echo "$NOS_THEME_BACKGROUND" | tr '/' '-')"

# Prefer rotating slideshow when themes/<name>/wallpapers/ has images
THEME_DIR=$(dirname "$NOS_THEME_BACKGROUND")
WALLPAPERS_DIR="$HOME/.local/share/nos/themes/$THEME_DIR/wallpapers"

set_wallpaper_uri() {
  local uri="$1"
  gsettings set org.gnome.desktop.background picture-uri "$uri"
  gsettings set org.gnome.desktop.background picture-uri-dark "$uri"
  gsettings set org.gnome.desktop.background picture-options 'zoom'
}

# Stock Ubuntu wallpapers as last-resort fallback (kept by bloat cleanup)
find_stock_ubuntu_wallpaper() {
  local candidate
  shopt -s nullglob
  for candidate in \
    /usr/share/backgrounds/warty-final-ubuntu.png \
    /usr/share/backgrounds/ubuntu-default-greyscale-wallpaper.png \
    /usr/share/backgrounds/*ubuntu*.jpg \
    /usr/share/backgrounds/*ubuntu*.png \
    /usr/share/backgrounds/*.jpg \
    /usr/share/backgrounds/*.png; do
    if [[ -f "$candidate" ]]; then
      echo "$candidate"
      shopt -u nullglob
      return 0
    fi
  done
  shopt -u nullglob
  return 1
}

if [ -d "$WALLPAPERS_DIR" ] && find "$WALLPAPERS_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | grep -q .; then
  bash "$HOME/.local/share/nos/bin/nos-set-wallpaper-slideshow.sh" "$WALLPAPERS_DIR"
elif [[ -f "$BACKGROUND_ORG_PATH" ]]; then
  mkdir -p "$BACKGROUND_DEST_DIR"
  [[ -f "$BACKGROUND_DEST_PATH" ]] || cp "$BACKGROUND_ORG_PATH" "$BACKGROUND_DEST_PATH"
  # GNOME requires a file:// URI; a bare path often yields a blank/black desktop.
  set_wallpaper_uri "file://$BACKGROUND_DEST_PATH"
else
  STOCK_BG=$(find_stock_ubuntu_wallpaper || true)
  if [[ -n "${STOCK_BG:-}" ]]; then
    echo "NOS theme wallpaper missing — using stock Ubuntu wallpaper: $STOCK_BG"
    set_wallpaper_uri "file://$STOCK_BG"
  else
    echo "WARNING: No NOS or stock wallpaper found; leaving GNOME background unchanged."
  fi
fi
