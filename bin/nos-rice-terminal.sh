#!/bin/bash

# Restore the full NOS riced terminal: Alacritty colors + transparency +
# CaskaydiaMono font + colorful prompt via Zellij "default" session.
# No sudo, no apt — safe to run inside the boring terminal.
#
#   bash ~/.local/share/nos/bin/nos-rice-terminal.sh [theme-slug]
#
# Theme slug (optional): velocity, tokyo-night, catppuccin, nord, ...

NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"
ALAC_DIR="$HOME/.config/alacritty"
ZEL_DIR="$HOME/.config/zellij"
STATE_DIR="$HOME/.config/nos"
mkdir -p "$ALAC_DIR" "$ZEL_DIR/themes" "$HOME/.local/bin" "$STATE_DIR"

# --- resolve theme: arg > saved > zellij config > current theme.toml > velocity
THEME="${1:-}"
THEME=$(echo "$THEME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
if [[ -z "$THEME" && -f "$STATE_DIR/theme" ]]; then
  THEME=$(tr -d '[:space:]' <"$STATE_DIR/theme")
fi
if [[ -z "$THEME" && -f "$ZEL_DIR/config.kdl" ]]; then
  THEME=$(grep -Eo 'theme "[^"]+"' "$ZEL_DIR/config.kdl" 2>/dev/null | head -1 | cut -d'"' -f2 || true)
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

# --- Alacritty: main config WITH imports (emergency fixes often wipe these)
cp "$NOS_PATH/configs/alacritty.toml" "$ALAC_DIR/alacritty.toml"
cp "$NOS_PATH/configs/alacritty/shared.toml" "$ALAC_DIR/shared.toml"
cp "$NOS_PATH/configs/alacritty/pane.toml" "$ALAC_DIR/pane.toml" 2>/dev/null || true
cp "$NOS_PATH/configs/alacritty/btop.toml" "$ALAC_DIR/btop.toml" 2>/dev/null || true
cp "$NOS_PATH/themes/$THEME/alacritty.toml" "$ALAC_DIR/theme.toml"
cp "$NOS_PATH/configs/alacritty/fonts/CaskaydiaMono.toml" "$ALAC_DIR/font.toml"
cp "$NOS_PATH/configs/alacritty/font-size.toml" "$ALAC_DIR/font-size.toml"

# --- Zellij: colorful session UI, always attach to "default"
cp "$NOS_PATH/configs/zellij.kdl" "$ZEL_DIR/config.kdl"
for theme_kdl in "$NOS_PATH"/themes/*/zellij.kdl; do
  [[ -f "$theme_kdl" ]] || continue
  name=$(basename "$(dirname "$theme_kdl")")
  cp "$theme_kdl" "$ZEL_DIR/themes/$name.kdl"
done
sed -i "s/theme \".*\"/theme \"$THEME\"/g" "$ZEL_DIR/config.kdl"

# --- launcher on PATH
chmod +x "$NOS_PATH/bin/nos-zellij.sh" 2>/dev/null || true
ln -sfn "$NOS_PATH/bin/nos-zellij.sh" "$HOME/.local/bin/nos-zellij"

# Sanity: never leave an import target empty/missing (that = boring terminal)
for f in theme.toml font.toml font-size.toml shared.toml; do
  [[ -s "$ALAC_DIR/$f" ]] || echo "WARNING: $ALAC_DIR/$f is empty/missing"
done

echo "Done. This window should recolor now (Alacritty live-reloads)."
echo "For the full Zellij rice: close this window, press Alt+t."
echo "If an old plain 'default' session reopens instead, run:"
echo "  zellij delete-session --force default"
echo "then Alt+t again."
