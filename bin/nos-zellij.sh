#!/bin/bash

# Alacritty → Zellij session "default" (create or attach).
# Never redirect the TUI away from the tty (that blanks the window).
# On any failure, exec bash so Alacritty never blinks closed.

export PATH="/usr/local/bin:/usr/bin:/bin:${HOME}/.local/bin:${PATH}"
export NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"

LOG="${TMPDIR:-/tmp}/nos-zellij.log"
log() { printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >>"$LOG" 2>/dev/null || true; }

fallback_bash() {
  log "falling back to bash: $*"
  exec /bin/bash -l
}

# Already inside Zellij — don't nest
[[ -z "${ZELLIJ:-}" ]] || exec /bin/bash -l

ZELLIJ_BIN="$(command -v zellij 2>/dev/null || true)"
[[ -z "$ZELLIJ_BIN" && -x /usr/local/bin/zellij ]] && ZELLIJ_BIN=/usr/local/bin/zellij
[[ -n "$ZELLIJ_BIN" ]] || fallback_bash "zellij not installed"

mkdir -p "$HOME/.config/zellij/themes"

# Preserve active theme name across template refresh
ACTIVE_THEME=""
if [[ -f "$HOME/.config/zellij/config.kdl" ]]; then
  ACTIVE_THEME=$(grep -Eo 'theme "[^"]+"' "$HOME/.config/zellij/config.kdl" 2>/dev/null | head -1 | cut -d'"' -f2 || true)
fi

# Refresh from NOS templates when available (fixes # comments / drift)
if [[ -f "$NOS_PATH/configs/zellij.kdl" ]]; then
  cp "$NOS_PATH/configs/zellij.kdl" "$HOME/.config/zellij/config.kdl" 2>/dev/null || true
fi
for theme_kdl in "$NOS_PATH"/themes/*/zellij.kdl; do
  [[ -f "$theme_kdl" ]] || continue
  name=$(basename "$(dirname "$theme_kdl")")
  cp "$theme_kdl" "$HOME/.config/zellij/themes/$name.kdl" 2>/dev/null || true
done

if [[ -n "$ACTIVE_THEME" && -f "$HOME/.config/zellij/config.kdl" ]]; then
  sed -i "s/theme \".*\"/theme \"$ACTIVE_THEME\"/g" "$HOME/.config/zellij/config.kdl" 2>/dev/null || true
fi

# Last-resort heal: convert illegal # comments if a broken file is still present
if [[ -f "$HOME/.config/zellij/config.kdl" ]] && grep -qE '^\s*#' "$HOME/.config/zellij/config.kdl" 2>/dev/null; then
  sed -i -E 's/^(\s*)#/\1\/\//' "$HOME/.config/zellij/config.kdl"
  log "converted # comments to // in config.kdl"
fi

CFG=()
if [[ -f "$HOME/.config/zellij/config.kdl" ]]; then
  CFG=(--config "$HOME/.config/zellij/config.kdl")
elif [[ -f "$NOS_PATH/configs/zellij.kdl" ]]; then
  CFG=(--config "$NOS_PATH/configs/zellij.kdl")
fi

SESSION=default
log "attach --create $SESSION (bin=$ZELLIJ_BIN)"

# CRITICAL: do not redirect stdout/stderr — Zellij draws on the tty.
# Only send diagnostics for non-interactive cleanup commands to the log.
"$ZELLIJ_BIN" "${CFG[@]}" attach --create "$SESSION"
status=$?
[[ $status -eq 0 ]] && exit 0
log "attach --create failed (exit $status); wiping session and retrying"

"$ZELLIJ_BIN" delete-session --force "$SESSION" >>"$LOG" 2>&1 || true
"$ZELLIJ_BIN" kill-session "$SESSION" >>"$LOG" 2>&1 || true

"$ZELLIJ_BIN" "${CFG[@]}" attach --create "$SESSION"
status=$?
[[ $status -eq 0 ]] && exit 0
log "retry failed (exit $status); trying plain 'zellij -s $SESSION'"

"$ZELLIJ_BIN" "${CFG[@]}" -s "$SESSION"
status=$?
[[ $status -eq 0 ]] && exit 0

# Last attempt: stock config only — still keep the tty
if [[ -f "$NOS_PATH/configs/zellij.kdl" ]]; then
  log "trying stock NOS config only"
  "$ZELLIJ_BIN" --config "$NOS_PATH/configs/zellij.kdl" -s "nos-recovery"
  status=$?
  [[ $status -eq 0 ]] && exit 0
fi

fallback_bash "zellij could not start (see $LOG)"
