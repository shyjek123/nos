#!/bin/bash

# Every Alt+t must join session "default" — no random-named sessions, no
# theme flip between windows. The new launcher only attaches (creating
# "default" in the background when absent); clean up dead sessions the
# old fallback chain left behind so the session picker stays clean.
echo "Making Alt+t always join Zellij session 'default'..."

chmod +x "$NOS_PATH/bin/nos-zellij.sh" 2>/dev/null || true
mkdir -p "$HOME/.local/bin"
ln -sfn "$NOS_PATH/bin/nos-zellij.sh" "$HOME/.local/bin/nos-zellij"

if command -v zellij >/dev/null 2>&1; then
  zellij list-sessions --no-formatting 2>/dev/null \
    | awk 'index($0, "EXITED") {print $1}' \
    | while read -r dead; do
        [[ -n "$dead" ]] && zellij delete-session --force "$dead" >/dev/null 2>&1 || true
      done
fi

echo "Done. If colors still differ, one full reset:"
echo "  zellij kill-all-sessions -y; zellij delete-all-sessions -f -y"
echo "then Alt+t creates a fresh 'default'."
