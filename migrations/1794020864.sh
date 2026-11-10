#!/bin/bash

# Interactive terminals use zsh (syntax highlighting + theme-colored listings).
# Bash stays available for scripts.

NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"

sudo apt-get update -y
sudo apt-get install -y zsh zsh-syntax-highlighting zsh-autosuggestions || true

if [[ -f "$HOME/.zshrc" && ! -f "$HOME/.zshrc.bak" ]]; then
  cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi
if [[ -f "$NOS_PATH/configs/zshrc" ]]; then
  cp "$NOS_PATH/configs/zshrc" "$HOME/.zshrc"
fi

if command -v zsh >/dev/null 2>&1 && [[ -f "$HOME/.config/zellij/config.kdl" ]]; then
  if grep -q '^default_shell ' "$HOME/.config/zellij/config.kdl"; then
    sed -i 's/^default_shell .*/default_shell "zsh"/' "$HOME/.config/zellij/config.kdl"
  else
    sed -i '1i default_shell "zsh"' "$HOME/.config/zellij/config.kdl"
  fi
fi
