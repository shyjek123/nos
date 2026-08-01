#!/bin/bash

# Joplin — open-source note-taking (AppImage). Alt+n launches joplin-desktop.
set -e

# AppImages need libfuse2 (Ubuntu 24.04+ package is libfuse2t64)
if ! ldconfig -p 2>/dev/null | grep -q 'libfuse.so.2'; then
  if apt-cache show libfuse2t64 &>/dev/null; then
    sudo apt install -y libfuse2t64
  else
    sudo apt install -y libfuse2
  fi
fi

curl -fsSL https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh |
  bash -s -- --silent

# Match official desktop entry: Ubuntu 23+ needs --no-sandbox for Electron
SANDBOX_ARGS=()
if command -v lsb_release &>/dev/null; then
  DIST=$(lsb_release -is 2>/dev/null || true)
  MAJOR=$(lsb_release -rs 2>/dev/null | cut -d. -f1 || true)
  if [[ "$DIST" =~ ^(Ubuntu|Tuxedo)$ ]] && [[ "${MAJOR:-0}" -ge 23 ]]; then
    SANDBOX_ARGS=(--no-sandbox)
  fi
fi

mkdir -p "$HOME/.local/bin"
{
  echo '#!/bin/bash'
  echo 'exec env APPIMAGELAUNCHER_DISABLE=TRUE "$HOME/.joplin/Joplin.AppImage"' "${SANDBOX_ARGS[*]}" '"$@"'
} >"$HOME/.local/bin/joplin-desktop"
chmod +x "$HOME/.local/bin/joplin-desktop"

echo "Joplin installed. Launch with: joplin-desktop (Alt+n)"
