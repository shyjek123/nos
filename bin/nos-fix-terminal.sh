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
# Emergency plain-bash shell (nos-fix-terminal).
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

# Never leave import targets empty — an empty theme.toml is the boring
# terminal. Fill any missing/empty file with the real NOS rice.
if [[ -f "$NOS_PATH/configs/alacritty/shared.toml" ]]; then
  [[ -s "$HOME/.config/alacritty/shared.toml" ]] || cp "$NOS_PATH/configs/alacritty/shared.toml" "$HOME/.config/alacritty/shared.toml"
  [[ -s "$HOME/.config/alacritty/font.toml" ]] || cp "$NOS_PATH/configs/alacritty/fonts/CaskaydiaMono.toml" "$HOME/.config/alacritty/font.toml"
  [[ -s "$HOME/.config/alacritty/font-size.toml" ]] || cp "$NOS_PATH/configs/alacritty/font-size.toml" "$HOME/.config/alacritty/font-size.toml"
  if [[ ! -s "$HOME/.config/alacritty/theme.toml" ]]; then
    EM_THEME="velocity"
    [[ -f "$HOME/.config/nos/theme" ]] && EM_THEME=$(tr -d '[:space:]' <"$HOME/.config/nos/theme")
    [[ -f "$NOS_PATH/themes/$EM_THEME/alacritty.toml" ]] || EM_THEME="velocity"
    cp "$NOS_PATH/themes/$EM_THEME/alacritty.toml" "$HOME/.config/alacritty/theme.toml"
  fi
fi
for f in theme.toml font.toml font-size.toml shared.toml; do
  [[ -f "$HOME/.config/alacritty/$f" ]] || touch "$HOME/.config/alacritty/$f"
done

# Retire the old Zellij auto-attach launcher
rm -f "$HOME/.local/bin/nos-zellij" "$HOME/.local/bin/nos-zellij.sh"

echo "Alacritty will now open bash. Press Alt+t (or launch Alacritty)."
