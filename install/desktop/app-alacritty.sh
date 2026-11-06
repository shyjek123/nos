#!/bin/bash

# Alacritty — default NOS terminal (About / Activity panes + interactive shell)
sudo apt install -y alacritty
mkdir -p ~/.config/alacritty ~/.local/bin

# Alacritty color theme only. Zellij is not configured or launched from here;
# its config is restored by install/terminal/app-zellij.sh when run manually.
ACTIVE_THEME=""
if [[ -f "$HOME/.config/nos/theme" ]]; then
  ACTIVE_THEME=$(tr -d '[:space:]' <"$HOME/.config/nos/theme")
fi
[[ -n "$ACTIVE_THEME" && -d "$NOS_PATH/themes/$ACTIVE_THEME" ]] || ACTIVE_THEME="velocity"
mkdir -p "$HOME/.config/nos"
echo "$ACTIVE_THEME" >"$HOME/.config/nos/theme"

# Remove the retired Zellij auto-attach launcher if a prior update added it
rm -f "$HOME/.local/bin/nos-zellij" "$HOME/.local/bin/nos-zellij.sh"

cp "$NOS_PATH/configs/alacritty.toml" ~/.config/alacritty/alacritty.toml
cp "$NOS_PATH/configs/alacritty/shared.toml" ~/.config/alacritty/shared.toml
cp "$NOS_PATH/configs/alacritty/pane.toml" ~/.config/alacritty/pane.toml
cp "$NOS_PATH/configs/alacritty/btop.toml" ~/.config/alacritty/btop.toml
cp "$NOS_PATH/configs/alacritty/fonts/CaskaydiaMono.toml" ~/.config/alacritty/font.toml
cp "$NOS_PATH/configs/alacritty/font-size.toml" ~/.config/alacritty/font-size.toml

if [[ -f "$NOS_PATH/themes/$ACTIVE_THEME/alacritty.toml" ]]; then
  cp "$NOS_PATH/themes/$ACTIVE_THEME/alacritty.toml" ~/.config/alacritty/theme.toml
else
  cp "$NOS_PATH/themes/velocity/alacritty.toml" ~/.config/alacritty/theme.toml
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
