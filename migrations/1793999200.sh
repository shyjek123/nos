#!/bin/bash

# Fix: bash: .../alacritty/extra/completions/alacritty.bash: No such file or directory
# Common after installing Alacritty from source into ~/alacritty, then switching to apt.

for rc in "$HOME/.bashrc" "$HOME/.bashrc.bak" "$HOME/.bash_profile" "$HOME/.profile"; do
  [[ -f "$rc" ]] || continue
  if grep -q 'alacritty/extra/completions/alacritty\.bash' "$rc" 2>/dev/null; then
    sed -i '\|alacritty/extra/completions/alacritty\.bash|d' "$rc"
    echo "Removed stale Alacritty completion source from $rc"
  fi
done
