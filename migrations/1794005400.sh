#!/bin/bash

# Restore the riced terminal (theme/transparency/font/Zellij) after the
# emergency plain-shell fix overwrote Alacritty's imports.
echo "Restoring riced Alacritty + Zellij theme..."
chmod +x "$NOS_PATH/bin/nos-rice-terminal.sh" 2>/dev/null || true
if [[ -f "$NOS_PATH/bin/nos-rice-terminal.sh" ]]; then
  bash "$NOS_PATH/bin/nos-rice-terminal.sh" || true
fi
