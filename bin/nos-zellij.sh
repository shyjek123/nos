#!/bin/bash

# Alacritty → Zellij session "default" (create or attach).
# Self-heals a broken config and falls back to bash so the window never blinks closed.

export PATH="/usr/local/bin:/usr/bin:/bin:${HOME}/.local/bin:${PATH}"
export NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"

LOG="${TMPDIR:-/tmp}/nos-zellij.log"
log() { printf '%s\n' "$*" >>"$LOG"; }

ZELLIJ_BIN="$(command -v zellij 2>/dev/null || true)"
[[ -z "$ZELLIJ_BIN" && -x /usr/local/bin/zellij ]] && ZELLIJ_BIN=/usr/local/bin/zellij

fallback_bash() {
  log "falling back to bash: $*"
  exec /bin/bash -l
}

[[ -n "$ZELLIJ_BIN" ]] || fallback_bash "zellij not installed"

# Already inside Zellij — don't nest
[[ -z "${ZELLIJ:-}" ]] || exec /bin/bash -l

mkdir -p "$HOME/.config/zellij/themes"

# Always refresh from NOS templates when available (fixes # comments / drift)
if [[ -f "$NOS_PATH/configs/zellij.kdl" ]]; then
  cp "$NOS_PATH/configs/zellij.kdl" "$HOME/.config/zellij/config.kdl"
fi
for theme_kdl in "$NOS_PATH"/themes/*/zellij.kdl; do
  [[ -f "$theme_kdl" ]] || continue
  name=$(basename "$(dirname "$theme_kdl")")
  cp "$theme_kdl" "$HOME/.config/zellij/themes/$name.kdl"
done

# Last-resort heal: convert illegal # comments if a broken file is still present
if [[ -f "$HOME/.config/zellij/config.kdl" ]] && grep -qE '^\s*#' "$HOME/.config/zellij/config.kdl"; then
  sed -i -E 's/^(\s*)#/\1\/\//' "$HOME/.config/zellij/config.kdl"
  log "converted # comments to // in config.kdl"
fi

CFG=(--config "$HOME/.config/zellij/config.kdl")
SESSION=default

# Try attach/create; on failure wipe dead session once and retry
if ! "$ZELLIJ_BIN" "${CFG[@]}" attach --create "$SESSION" >>"$LOG" 2>&1; then
  log "attach --create failed; deleting session '$SESSION' and retrying"
  "$ZELLIJ_BIN" delete-session --force "$SESSION" >>"$LOG" 2>&1 || true
  "$ZELLIJ_BIN" kill-session "$SESSION" >>"$LOG" 2>&1 || true
  if ! "$ZELLIJ_BIN" "${CFG[@]}" attach --create "$SESSION" >>"$LOG" 2>&1; then
    log "retry failed; trying plain 'zellij -s $SESSION'"
    if ! "$ZELLIJ_BIN" "${CFG[@]}" -s "$SESSION" >>"$LOG" 2>&1; then
      fallback_bash "zellij could not start session '$SESSION' (see $LOG)"
    fi
  fi
fi
