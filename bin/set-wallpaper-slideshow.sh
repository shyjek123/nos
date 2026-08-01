#!/bin/bash

# Build a GNOME desktop background slideshow XML from a folder of images.
# Usage: nos-set-wallpaper-slideshow.sh <images-dir> [duration-seconds] [transition-seconds]

set -e

IMAGES_DIR="${1:-}"
DURATION="${2:-300}"
TRANSITION="${3:-5}"

if [ -z "$IMAGES_DIR" ] || [ ! -d "$IMAGES_DIR" ]; then
  echo "Usage: $0 <images-dir> [static-duration-seconds] [transition-seconds]"
  exit 1
fi

mapfile -t IMAGES < <(find "$IMAGES_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort)

if [ "${#IMAGES[@]}" -eq 0 ]; then
  echo "No images found in $IMAGES_DIR"
  exit 1
fi

DEST_DIR="$HOME/.local/share/backgrounds"
mkdir -p "$DEST_DIR"

THEME_SLUG=$(basename "$(dirname "$IMAGES_DIR")")
if [ "$(basename "$IMAGES_DIR")" != "wallpapers" ]; then
  THEME_SLUG=$(basename "$IMAGES_DIR")
fi

COPIED=()
for img in "${IMAGES[@]}"; do
  base=$(basename "$img")
  dest="$DEST_DIR/${THEME_SLUG}-${base}"
  cp -f "$img" "$dest"
  COPIED+=("$dest")
done

XML_PATH="$DEST_DIR/${THEME_SLUG}-slideshow.xml"

{
  echo '<background>'
  echo '  <starttime>'
  echo '    <year>2024</year>'
  echo '    <month>01</month>'
  echo '    <day>01</day>'
  echo '    <hour>00</hour>'
  echo '    <minute>00</minute>'
  echo '    <second>00</second>'
  echo '  </starttime>'

  count=${#COPIED[@]}
  for i in "${!COPIED[@]}"; do
    current="${COPIED[$i]}"
    next="${COPIED[$(( (i + 1) % count ))]}"

    echo '  <static>'
    echo "    <duration>${DURATION}.0</duration>"
    echo "    <file>${current}</file>"
    echo '  </static>'

    if [ "$count" -gt 1 ]; then
      echo '  <transition>'
      echo "    <duration>${TRANSITION}.0</duration>"
      echo "    <from>${current}</from>"
      echo "    <to>${next}</to>"
      echo '  </transition>'
    fi
  done

  echo '</background>'
} >"$XML_PATH"

URI="file://$XML_PATH"
gsettings set org.gnome.desktop.background picture-uri "$URI"
gsettings set org.gnome.desktop.background picture-uri-dark "$URI"
gsettings set org.gnome.desktop.background picture-options 'zoom'

echo "Wallpaper slideshow set: $XML_PATH (${#COPIED[@]} images, ${DURATION}s each)"
