#!/bin/bash

# Apply a NOS theme by slug (e.g. velocity, tokyo-night).
# Usage: source themes/switch-theme.sh <theme-slug>
#    or: THEME=velocity source themes/switch-theme.sh

THEME="${1:-$THEME}"
THEME=$(echo "$THEME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
NOS_ROOT="${NOS_PATH:-$HOME/.local/share/nos}"

if [[ -z "$THEME" || "$THEME" == "<<-back" ]]; then
  return 0 2>/dev/null || exit 0
fi

THEME_DIR="$NOS_ROOT/themes/$THEME"
if [[ ! -d "$THEME_DIR" ]]; then
  echo "Unknown theme: $THEME"
  return 1 2>/dev/null || exit 1
fi

# Seed configs if missing so theme selection can stick
if [[ ! -f "$HOME/.config/zellij/config.kdl" && -f "$NOS_ROOT/configs/zellij.kdl" ]]; then
  mkdir -p ~/.config/zellij
  cp "$NOS_ROOT/configs/zellij.kdl" ~/.config/zellij/config.kdl
fi
if [[ ! -f "$HOME/.config/btop/btop.conf" && -f "$NOS_ROOT/configs/btop.conf" ]]; then
  mkdir -p ~/.config/btop
  cp "$NOS_ROOT/configs/btop.conf" ~/.config/btop/btop.conf
fi

# Alacritty (About / Activity / fallback terminal)
if [[ -d "$HOME/.config/alacritty" && -f "$THEME_DIR/alacritty.toml" ]]; then
  cp "$THEME_DIR/alacritty.toml" ~/.config/alacritty/theme.toml
fi

# Ghostty (default terminal) — same loader as set-gnome-theme.sh / Omakub Alacritty flow
if [[ -f "$THEME_DIR/ghostty" ]]; then
  mkdir -p "$HOME/.config/ghostty/themes"
  cp "$THEME_DIR/ghostty" "$HOME/.config/ghostty/themes/$THEME"
  cp "$THEME_DIR/ghostty" "$HOME/.config/ghostty/theme"
  if [[ -f "$HOME/.config/ghostty/config" ]]; then
    sed -i '/^config-file[[:space:]]*=/d' "$HOME/.config/ghostty/config"
    if grep -q '^theme[[:space:]]*=' "$HOME/.config/ghostty/config"; then
      sed -i "s|^theme[[:space:]]*=.*|theme = ${THEME}|" "$HOME/.config/ghostty/config"
    else
      sed -i "1i theme = ${THEME}" "$HOME/.config/ghostty/config"
    fi
  fi
fi

# Zellij (manual sessions)
if [[ -f "$THEME_DIR/zellij.kdl" ]]; then
  mkdir -p ~/.config/zellij/themes
  cp "$THEME_DIR/zellij.kdl" ~/.config/zellij/themes/"$THEME".kdl
  if [[ -f "$HOME/.config/zellij/config.kdl" ]]; then
    sed -i "s/theme \".*\"/theme \"$THEME\"/g" ~/.config/zellij/config.kdl
  fi
fi

# btop
if [[ -f "$THEME_DIR/btop.theme" ]]; then
  mkdir -p ~/.config/btop/themes
  cp "$THEME_DIR/btop.theme" ~/.config/btop/themes/"$THEME".theme
  if [[ -f "$HOME/.config/btop/btop.conf" ]]; then
    sed -i "s/color_theme = \".*\"/color_theme = \"$THEME\"/g" ~/.config/btop/btop.conf
  fi
elif [[ -f "$HOME/.config/btop/btop.conf" ]]; then
  sed -i "s/color_theme = \".*\"/color_theme = \"Default\"/g" ~/.config/btop/btop.conf
fi

# GNOME + TopHat + VS Code
[[ -f "$THEME_DIR/gnome.sh" ]] && source "$THEME_DIR/gnome.sh"
[[ -f "$THEME_DIR/tophat.sh" ]] && source "$THEME_DIR/tophat.sh"
[[ -f "$THEME_DIR/vscode.sh" ]] && source "$THEME_DIR/vscode.sh"

echo "Theme applied: $THEME"
