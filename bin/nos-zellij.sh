#!/bin/bash

# Alacritty login shell → always join Zellij session "default".
# Creates the session on first launch; later windows re-attach to it.

export PATH="/usr/local/bin:/usr/bin:/bin:${HOME}/.local/bin:${PATH}"
export NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"

ZELLIJ_BIN="$(command -v zellij || true)"
if [[ -z "$ZELLIJ_BIN" && -x /usr/local/bin/zellij ]]; then
  ZELLIJ_BIN=/usr/local/bin/zellij
fi

if [[ -z "$ZELLIJ_BIN" ]]; then
  echo "nos-zellij: zellij not installed; falling back to bash" >&2
  exec /bin/bash -l
fi

# Prefer NOS config if present (avoids a broken user config blocking startup)
CFG=()
if [[ -f "$HOME/.config/zellij/config.kdl" ]]; then
  CFG=(--config "$HOME/.config/zellij/config.kdl")
elif [[ -f "$NOS_PATH/configs/zellij.kdl" ]]; then
  CFG=(--config "$NOS_PATH/configs/zellij.kdl")
fi

# Primary path: attach or create the named session
exec "$ZELLIJ_BIN" "${CFG[@]}" attach --create default
