#!/bin/bash

# Un-blank Alacritty: prior nos-zellij redirected the TUI to a log file.
echo "Restoring Zellij TTY launch (no stdout redirect)..."

chmod +x "$NOS_PATH/bin/nos-zellij.sh" 2>/dev/null || true
mkdir -p "$HOME/.local/bin" "$HOME/.config/zellij/themes" "$HOME/.config/alacritty"
ln -sfn "$NOS_PATH/bin/nos-zellij.sh" "$HOME/.local/bin/nos-zellij"

# Install fixed launcher + Alacritty shell immediately (don't wait on full app script)
if [[ -f "$NOS_PATH/bin/nos-zellij.sh" ]]; then
  cp "$NOS_PATH/bin/nos-zellij.sh" "$HOME/.local/bin/nos-zellij.sh" 2>/dev/null || true
fi
if [[ -f "$NOS_PATH/configs/alacritty.toml" ]]; then
  cp "$NOS_PATH/configs/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
fi
if [[ -f "$NOS_PATH/configs/zellij.kdl" ]]; then
  cp "$NOS_PATH/configs/zellij.kdl" "$HOME/.config/zellij/config.kdl"
fi

# Drop any dead default session that may block attach
if command -v zellij >/dev/null 2>&1; then
  zellij delete-session --force default >/dev/null 2>&1 || true
  zellij kill-session default >/dev/null 2>&1 || true
fi

if [[ -f "$NOS_PATH/install/desktop/app-alacritty.sh" ]]; then
  # shellcheck disable=SC1091
  source "$NOS_PATH/install/desktop/app-alacritty.sh" || true
fi

echo "Terminal launcher repaired. Open Alt+t (or: alacritty -e bash)."
