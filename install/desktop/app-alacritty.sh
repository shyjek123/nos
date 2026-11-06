#!/bin/bash

# Alacritty — default NOS terminal (About / Activity panes + interactive shell)
sudo apt install -y alacritty
mkdir -p ~/.config/alacritty ~/.config/zellij/themes

cp "$NOS_PATH/configs/alacritty.toml" ~/.config/alacritty/alacritty.toml
cp "$NOS_PATH/configs/alacritty/shared.toml" ~/.config/alacritty/shared.toml
cp "$NOS_PATH/configs/alacritty/pane.toml" ~/.config/alacritty/pane.toml
cp "$NOS_PATH/configs/alacritty/btop.toml" ~/.config/alacritty/btop.toml
cp "$NOS_PATH/configs/alacritty/fonts/CaskaydiaMono.toml" ~/.config/alacritty/font.toml
cp "$NOS_PATH/configs/alacritty/font-size.toml" ~/.config/alacritty/font-size.toml

# Prefer active NOS theme colors if present, else Velocity (Ghostty-era default)
ACTIVE_THEME="velocity"
if [[ -f "$HOME/.config/zellij/config.kdl" ]]; then
  ACTIVE_THEME=$(grep -Eo 'theme "[^"]+"' "$HOME/.config/zellij/config.kdl" 2>/dev/null | head -1 | cut -d'"' -f2 || echo velocity)
fi
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
