#!/bin/bash

# Fix Zellij config parse failure (# comments are invalid KDL) and default session attach
echo "Fixing Zellij config + default session launcher..."

chmod +x "$NOS_PATH/bin/nos-zellij.sh" 2>/dev/null || true
mkdir -p "$HOME/.config/zellij/themes" "$HOME/.local/bin"
ln -sfn "$NOS_PATH/bin/nos-zellij.sh" "$HOME/.local/bin/nos-zellij"

if [[ -f "$NOS_PATH/configs/zellij.kdl" ]]; then
  cp "$NOS_PATH/configs/zellij.kdl" "$HOME/.config/zellij/config.kdl"
fi

for theme_kdl in "$NOS_PATH"/themes/*/zellij.kdl; do
  [[ -f "$theme_kdl" ]] || continue
  name=$(basename "$(dirname "$theme_kdl")")
  cp "$theme_kdl" "$HOME/.config/zellij/themes/$name.kdl"
done

# Refresh Alacritty so it launches nos-zellij.sh
if [[ -f "$NOS_PATH/install/desktop/app-alacritty.sh" ]]; then
  # shellcheck disable=SC1091
  source "$NOS_PATH/install/desktop/app-alacritty.sh"
fi

echo "Zellij will attach to session 'default' on Alt+t."
