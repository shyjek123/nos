#!/bin/bash

# Launcher used by Alacritty so GUI/hotkey starts still find Zellij.
# Falls back to a login bash if Zellij is missing or fails (avoids blink-and-close).

export PATH="/usr/local/bin:/usr/bin:/bin:${HOME}/.local/bin:${PATH}"

# Prefer a stable named session; create it if needed.
if command -v zellij >/dev/null 2>&1; then
  # Older/newer CLI quirks: try attach --create, then plain session start.
  if zellij attach --create default 2>/tmp/nos-zellij.err; then
    exit 0
  fi
  # Session exists but attach flag unsupported — try attach only, then create.
  if zellij attach default 2>>/tmp/nos-zellij.err; then
    exit 0
  fi
  if zellij -s default 2>>/tmp/nos-zellij.err; then
    exit 0
  fi
  # Last resort: any zellij session rather than a blank flash
  if zellij 2>>/tmp/nos-zellij.err; then
    exit 0
  fi
  echo "nos-zellij: zellij failed; see /tmp/nos-zellij.err" >&2
fi

exec /bin/bash -l
