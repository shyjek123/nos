#!/bin/bash

# Remove NOS itself (configs, path hooks, and install tree). Does not purge every app.

if ! gum confirm "Remove NOS from this machine? (apps like Firefox/VS Code stay unless you uninstall them separately)"; then
  echo "Cancelled."
  return 0 2>/dev/null || exit 0
fi

# Signal caller to exit without re-entering the TUI
export NOS_UNINSTALLED=1

# Restore previous bashrc/inputrc if we backed them up
[[ -f ~/.bashrc.bak ]] && mv -f ~/.bashrc.bak ~/.bashrc
[[ -f ~/.inputrc.bak ]] && mv -f ~/.inputrc.bak ~/.inputrc

# Drop NOS desktop launchers
rm -f ~/.local/share/applications/Nos.desktop
rm -f ~/.local/share/applications/About.desktop
rm -f ~/.local/share/applications/Activity.desktop
rm -f ~/.local/share/applications/Docker.desktop
rm -f ~/.local/share/applications/Neovim.desktop

rm -f "$HOME/.local/bin/nos"

# Move tree aside first so this script (already sourced) does not need it;
# delete asynchronously after the caller exits the TUI.
NOS_DIR="${NOS_PATH:-$HOME/.local/share/nos}"
if [[ -d "$NOS_DIR" ]]; then
  STAGE=$(mktemp -d /tmp/nos-removed.XXXXXX)
  mv "$NOS_DIR" "$STAGE/nos" 2>/dev/null || rm -rf "$NOS_DIR"
  (sleep 2 && rm -rf "$STAGE") &>/dev/null &
fi

echo "NOS removed. Open a new shell (or log out) so PATH/bashrc changes take effect."
return 0 2>/dev/null || exit 0
