#!/bin/bash

# Restore the NOS riced Alacritty look: colors + transparency + CaskaydiaMono.
# Alacritty opens its default shell — Zellij is not launched or configured here.
# No sudo, no apt — safe to run inside the terminal.
#
#   bash ~/.local/share/nos/bin/nos-rice-terminal.sh [theme-slug]
#
# Theme slug (optional): velocity, tokyo-night, catppuccin, nord, ...

NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"
ALAC_DIR="$HOME/.config/alacritty"
STATE_DIR="$HOME/.config/nos"
mkdir -p "$ALAC_DIR" "$HOME/.local/bin" "$STATE_DIR"

# --- resolve theme: arg > saved > current theme.toml match > velocity
THEME="${1:-}"
THEME=$(echo "$THEME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
if [[ -z "$THEME" && -f "$STATE_DIR/theme" ]]; then
  THEME=$(tr -d '[:space:]' <"$STATE_DIR/theme")
fi
if [[ -z "$THEME" && -f "$ALAC_DIR/theme.toml" ]]; then
  for candidate in "$NOS_PATH"/themes/*/alacritty.toml; do
    [[ -f "$candidate" ]] || continue
    if cmp -s "$candidate" "$ALAC_DIR/theme.toml"; then
      THEME=$(basename "$(dirname "$candidate")")
      break
    fi
  done
fi
[[ -n "$THEME" && -d "$NOS_PATH/themes/$THEME" ]] || THEME="velocity"
echo "$THEME" >"$STATE_DIR/theme"
echo "==> Restoring riced terminal (theme: $THEME)"

cp "$NOS_PATH/configs/alacritty.toml" "$ALAC_DIR/alacritty.toml"
cp "$NOS_PATH/configs/alacritty/shared.toml" "$ALAC_DIR/shared.toml"
cp "$NOS_PATH/configs/alacritty/pane.toml" "$ALAC_DIR/pane.toml" 2>/dev/null || true
cp "$NOS_PATH/configs/alacritty/btop.toml" "$ALAC_DIR/btop.toml" 2>/dev/null || true
cp "$NOS_PATH/themes/$THEME/alacritty.toml" "$ALAC_DIR/theme.toml"
cp "$NOS_PATH/configs/alacritty/fonts/CaskaydiaMono.toml" "$ALAC_DIR/font.toml"
cp "$NOS_PATH/configs/alacritty/font-size.toml" "$ALAC_DIR/font-size.toml"

# Retire the old Zellij auto-attach launcher
rm -f "$HOME/.local/bin/nos-zellij" "$HOME/.local/bin/nos-zellij.sh"

# Sanity: never leave an import target empty/missing (that = boring terminal)
for f in theme.toml font.toml font-size.toml shared.toml; do
  [[ -s "$ALAC_DIR/$f" ]] || echo "WARNING: $ALAC_DIR/$f is empty/missing"
done

echo "Done. This window should recolor now (Alacritty live-reloads)."
echo "Close it and press Alt+t for a fresh default-shell terminal."
