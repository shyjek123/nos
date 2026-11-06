#!/bin/bash

# Alacritty → Zellij session "default". EVERY launch joins that one session.
# Never create a random/other-named session, never redirect the TUI away
# from the tty (that blanks the window), and fall back to bash on failure.

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

SESSION=default
CFG_FILE="$HOME/.config/zellij/config.kdl"

# Refresh/heal the on-disk config. Only called when a NEW session is about
# to be created (or the file is broken) — rewriting it on every launch raced
# between windows and flipped themes (template copy lands before the sed
# that restores the active theme).
heal_config() {
  mkdir -p "$HOME/.config/zellij/themes"
  local active=""
  if [[ -f "$HOME/.config/nos/theme" ]]; then
    active=$(tr -d '[:space:]' <"$HOME/.config/nos/theme")
  fi
  if [[ -z "$active" && -f "$CFG_FILE" ]]; then
    active=$(grep -Eo 'theme "[^"]+"' "$CFG_FILE" 2>/dev/null | head -1 | cut -d'"' -f2 || true)
  fi
  if [[ -f "$NOS_PATH/configs/zellij.kdl" ]]; then
    cp "$NOS_PATH/configs/zellij.kdl" "$CFG_FILE" 2>/dev/null || true
  fi
  for theme_kdl in "$NOS_PATH"/themes/*/zellij.kdl; do
    [[ -f "$theme_kdl" ]] || continue
    local name
    name=$(basename "$(dirname "$theme_kdl")")
    cp "$theme_kdl" "$HOME/.config/zellij/themes/$name.kdl" 2>/dev/null || true
  done
  if [[ -n "$active" && -f "$CFG_FILE" ]]; then
    sed -i "s/theme \".*\"/theme \"$active\"/g" "$CFG_FILE" 2>/dev/null || true
  fi
  if [[ -f "$CFG_FILE" ]] && grep -qE '^\s*#' "$CFG_FILE" 2>/dev/null; then
    sed -i -E 's/^(\s*)#/\1\/\//' "$CFG_FILE"
    log "converted # comments to // in config.kdl"
  fi
}

# alive | exited | absent
session_state() {
  "$ZELLIJ_BIN" list-sessions --no-formatting 2>/dev/null | awk -v s="$SESSION" '
    $1 == s { print (index($0, "EXITED") ? "exited" : "alive"); found = 1 }
    END { if (!found) print "absent" }'
}

CFG=()
[[ -f "$CFG_FILE" ]] && CFG=(--config "$CFG_FILE")

# Serialize session creation: rapid Alt+t presses must not race to create
# two sessions (one wins a random name / template theme). Hold an flock
# only while deciding + creating in the background, never while attached.
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/nos-zellij-default.lock"
exec 9>"$LOCK_FILE" 2>/dev/null || true
if [[ -e /proc/$$/fd/9 ]]; then
  flock -w 15 9 2>/dev/null || log "flock timeout; continuing without lock"
fi

STATE=$(session_state)
log "session '$SESSION' state: $STATE"
if [[ "$STATE" == "exited" ]]; then
  "$ZELLIJ_BIN" delete-session --force "$SESSION" >>"$LOG" 2>&1 || true
  STATE=absent
fi

if [[ "$STATE" != "alive" ]]; then
  heal_config
  [[ -f "$CFG_FILE" ]] && CFG=(--config "$CFG_FILE")
  # Create the one true session detached, then every window just attaches.
  if ! "$ZELLIJ_BIN" "${CFG[@]}" attach --create-background "$SESSION" >>"$LOG" 2>&1; then
    log "create-background unsupported/failed; attach --create will handle it"
  fi
fi

# Release the lock before the interactive attach
flock -u 9 2>/dev/null || true
exec 9>&-

# CRITICAL: no redirects here — Zellij draws on the tty.
"$ZELLIJ_BIN" "${CFG[@]}" attach "$SESSION"
status=$?
[[ $status -eq 0 ]] && exit 0
log "attach failed (exit $status); healing config and retrying with --create"

heal_config
[[ -f "$CFG_FILE" ]] && CFG=(--config "$CFG_FILE")
"$ZELLIJ_BIN" "${CFG[@]}" attach --create "$SESSION"
status=$?
[[ $status -eq 0 ]] && exit 0

fallback_bash "zellij could not join session '$SESSION' (see $LOG)"
