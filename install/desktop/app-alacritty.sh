#!/bin/bash

# Alacritty — default NOS terminal (About / Activity panes + interactive shell)
sudo apt install -y alacritty
mkdir -p ~/.config/alacritty ~/.config/zellij/themes ~/.local/bin

# Capture the user's theme BEFORE anything overwrites zellij/config.kdl,
# otherwise the template's theme always wins and the rice resets.
ACTIVE_THEME=""
if [[ -f "$HOME/.config/nos/theme" ]]; then
  ACTIVE_THEME=$(tr -d '[:space:]' <"$HOME/.config/nos/theme")
fi
if [[ -z "$ACTIVE_THEME" && -f "$HOME/.config/zellij/config.kdl" ]]; then
  ACTIVE_THEME=$(grep -Eo 'theme "[^"]+"' "$HOME/.config/zellij/config.kdl" 2>/dev/null | head -1 | cut -d'"' -f2 || true)
fi
[[ -n "$ACTIVE_THEME" && -d "$NOS_PATH/themes/$ACTIVE_THEME" ]] || ACTIVE_THEME="velocity"
mkdir -p "$HOME/.config/nos"
echo "$ACTIVE_THEME" >"$HOME/.config/nos/theme"

# Zellij launcher on PATH for GUI/hotkey starts (minimal PATH)
chmod +x "$NOS_PATH/bin/nos-zellij.sh"
ln -sfn "$NOS_PATH/bin/nos-zellij.sh" "$HOME/.local/bin/nos-zellij"

# Keep Zellij config healthy (KDL rejects # comments — that blinks Alacritty closed)
mkdir -p ~/.config/zellij/themes
if [[ -f "$NOS_PATH/configs/zellij.kdl" ]]; then
  cp "$NOS_PATH/configs/zellij.kdl" ~/.config/zellij/config.kdl
fi
for theme_kdl in "$NOS_PATH"/themes/*/zellij.kdl; do
  [[ -f "$theme_kdl" ]] || continue
  name=$(basename "$(dirname "$theme_kdl")")
  cp "$theme_kdl" ~/.config/zellij/themes/"$name".kdl
done

cp "$NOS_PATH/configs/alacritty.toml" ~/.config/alacritty/alacritty.toml
cp "$NOS_PATH/configs/alacritty/shared.toml" ~/.config/alacritty/shared.toml
cp "$NOS_PATH/configs/alacritty/pane.toml" ~/.config/alacritty/pane.toml
cp "$NOS_PATH/configs/alacritty/btop.toml" ~/.config/alacritty/btop.toml
cp "$NOS_PATH/configs/alacritty/fonts/CaskaydiaMono.toml" ~/.config/alacritty/font.toml
cp "$NOS_PATH/configs/alacritty/font-size.toml" ~/.config/alacritty/font-size.toml

# Theme resolved at the top of this script (before config.kdl was overwritten)
if [[ -f "$NOS_PATH/themes/$ACTIVE_THEME/alacritty.toml" ]]; then
  cp "$NOS_PATH/themes/$ACTIVE_THEME/alacritty.toml" ~/.config/alacritty/theme.toml
else
  cp "$NOS_PATH/themes/velocity/alacritty.toml" ~/.config/alacritty/theme.toml
fi

# Zellij: always attach/create the named "default" session from Alacritty
cp "$NOS_PATH/configs/zellij.kdl" ~/.config/zellij/config.kdl
if [[ -f "$NOS_PATH/themes/$ACTIVE_THEME/zellij.kdl" ]]; then
  cp "$NOS_PATH/themes/$ACTIVE_THEME/zellij.kdl" ~/.config/zellij/themes/"$ACTIVE_THEME".kdl
  sed -i "s/theme \".*\"/theme \"$ACTIVE_THEME\"/g" ~/.config/zellij/config.kdl
fi

# Migrate config format if needed (Alacritty 0.13+)
alacritty migrate 2>/dev/null || true
alacritty migrate -c ~/.config/alacritty/pane.toml 2>/dev/null || true
alacritty migrate -c ~/.config/alacritty/btop.toml 2>/dev/null || true

# Drop stale source-build completion lines (e.g. ~/alacritty/extra/completions/...)
# that error after the git checkout is deleted or apt Alacritty is used instead.
for rc in "$HOME/.bashrc" "$HOME/.bashrc.bak" "$HOME/.bash_profile" "$HOME/.profile"; do
  [[ -f "$rc" ]] || continue
  if grep -q 'alacritty/extra/completions/alacritty\.bash' "$rc" 2>/dev/null; then
    sed -i '\|alacritty/extra/completions/alacritty\.bash|d' "$rc"
    echo "Removed stale Alacritty completion source from $rc"
  fi
done

source "$NOS_PATH/install/desktop/set-alacritty-default.sh"
