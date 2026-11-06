#!/bin/bash

# Remove all NOS changes to Zellij and restore the default:
# - Alacritty opens its default shell again (no Zellij auto-attach)
# - ~/.config/zellij/config.kdl back to the NOS default in configs/zellij.kdl
# - retired nos-zellij launcher/symlinks removed
# Running sessions are left alone (killing them could close this terminal);
# dead sessions are cleaned up.
echo "Restoring default Zellij (manual-only) + plain Alacritty shell..."

NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"
mkdir -p "$HOME/.config/zellij" "$HOME/.config/alacritty" "$HOME/.local/bin"

rm -f "$HOME/.local/bin/nos-zellij" "$HOME/.local/bin/nos-zellij.sh"

if [[ -f "$NOS_PATH/configs/zellij.kdl" ]]; then
  cp "$NOS_PATH/configs/zellij.kdl" "$HOME/.config/zellij/config.kdl"
fi

# Alacritty rice without any [shell] override (default shell)
if [[ -f "$NOS_PATH/bin/nos-rice-terminal.sh" ]]; then
  bash "$NOS_PATH/bin/nos-rice-terminal.sh" || true
elif [[ -f "$NOS_PATH/configs/alacritty.toml" ]]; then
  cp "$NOS_PATH/configs/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
fi

if command -v zellij >/dev/null 2>&1; then
  zellij list-sessions --no-formatting 2>/dev/null \
    | awk 'index($0, "EXITED") {print $1}' \
    | while read -r dead; do
        [[ -n "$dead" ]] && zellij delete-session --force "$dead" >/dev/null 2>&1 || true
      done
fi

echo "Done. Alt+t now opens a plain Alacritty shell; run 'zellij' manually for the default NOS Zellij config."
echo "To also drop sessions still running from the old setup: zellij kill-all-sessions -y"
