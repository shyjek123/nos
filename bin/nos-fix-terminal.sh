#!/bin/bash

# Emergency: make Alacritty open a plain bash shell (no Zellij).
# Safe to run from Alt+F2 → Run a Command:
#   bash $HOME/.local/share/nos/bin/nos-fix-terminal.sh
# or, if NOS is not updated yet:
#   bash -c 'mkdir -p ~/.config/alacritty; printf "%s\n" "[shell]" "program = \"/bin/bash\"" "args = [\"-l\"]" > ~/.config/alacritty/alacritty.toml'

set -euo pipefail

NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"
mkdir -p "$HOME/.config/alacritty" "$HOME/.local/bin"

cat >"$HOME/.config/alacritty/alacritty.toml" <<'EOF'
# Emergency plain-bash shell (nos-fix-terminal). Re-run nos update / app-alacritty to restore Zellij.
[general]
import = [
  "~/.config/alacritty/theme.toml",
  "~/.config/alacritty/font.toml",
  "~/.config/alacritty/font-size.toml",
  "~/.config/alacritty/shared.toml",
]

[shell]
program = "/bin/bash"
args = ["-l"]
EOF

# Keep imports from breaking if theme/font files are missing
for f in theme.toml font.toml font-size.toml shared.toml; do
  [[ -f "$HOME/.config/alacritty/$f" ]] || touch "$HOME/.config/alacritty/$f"
done

# Also refresh launcher from NOS when present (full fix)
if [[ -f "$NOS_PATH/bin/nos-zellij.sh" ]]; then
  chmod +x "$NOS_PATH/bin/nos-zellij.sh"
  ln -sfn "$NOS_PATH/bin/nos-zellij.sh" "$HOME/.local/bin/nos-zellij"
fi

echo "Alacritty will now open bash. Press Alt+t (or launch Alacritty)."
echo "After NOS update, restore Zellij with:"
echo "  source \"$NOS_PATH/install/desktop/app-alacritty.sh\""
