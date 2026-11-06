#!/bin/bash

# Convert a legacy git-based ~/.local/share/nos into a plain install folder.
# Safe no-op if already converted.

NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"
mkdir -p "$NOS_PATH/state"

if [[ -d "$NOS_PATH/.git" ]]; then
  echo "Removing .git from $NOS_PATH (NOS is an install folder, not a repo you manage)..."
  # Capture last commit time before deleting metadata
  if [[ ! -f "$NOS_PATH/state/updated-at" ]]; then
    git -C "$NOS_PATH" log -1 --format=%cd --date=unix 2>/dev/null >"$NOS_PATH/state/updated-at" || date +%s >"$NOS_PATH/state/updated-at"
  fi
  rm -rf "$NOS_PATH/.git"
fi

if [[ ! -f "$NOS_PATH/state/upstream" ]]; then
  cat >"$NOS_PATH/state/upstream" <<EOF
repo=https://github.com/shyjek123/nos
ref=main
synced_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
fi
