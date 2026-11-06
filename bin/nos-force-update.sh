#!/bin/bash

# Force-refresh ~/.local/share/nos from GitHub with no git pull / commit / stash.
# Safe to download and run even when the install dir is a dirty git checkout.
#
# IMPORTANT: when piping to bash, put env vars AFTER the pipe (or pass the ref as $1):
#   curl -fsSL .../nos-force-update.sh | NOS_REF=cursor/fix-black-screen-2ef7 bash
#   curl -fsSL .../nos-force-update.sh | bash -s -- cursor/fix-black-screen-2ef7
#
# Wrong (NOS_REF only applies to curl, bash still uses main):
#   NOS_REF=cursor/fix-black-screen-2ef7 curl ... | bash

set -euo pipefail

NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"
# Prefer CLI arg (bash -s -- ref), then env, then main
NOS_REF="${1:-${NOS_REF:-main}}"
NOS_REPO="${NOS_REPO:-https://github.com/shyjek123/nos}"
NOS_REPO="${NOS_REPO%.git}"

echo "==> Force-updating NOS at $NOS_PATH"
echo "    repo=$NOS_REPO  ref=$NOS_REF"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

archive="${NOS_REPO}/archive/refs/heads/${NOS_REF}.tar.gz"
if ! curl -fsSL "$archive" -o "$tmp/nos.tar.gz" 2>/dev/null; then
  archive="${NOS_REPO}/archive/refs/tags/${NOS_REF}.tar.gz"
  curl -fsSL "$archive" -o "$tmp/nos.tar.gz"
fi

mkdir -p "$tmp/extract"
tar -xzf "$tmp/nos.tar.gz" -C "$tmp/extract"
src=$(find "$tmp/extract" -mindepth 1 -maxdepth 1 -type d | head -n 1)

if [[ -z "$src" || ! -f "$src/install.sh" ]]; then
  echo "ERROR: archive did not contain install.sh"
  exit 1
fi

mkdir -p "$NOS_PATH/state" 2>/dev/null || true

# Remember prior update stamp / legacy git time for migrations
if [[ -f "$NOS_PATH/state/updated-at" ]]; then
  last_updated_at=$(tr -d '[:space:]' <"$NOS_PATH/state/updated-at")
elif [[ -d "$NOS_PATH/.git" ]]; then
  last_updated_at=$(git -C "$NOS_PATH" log -1 --format=%cd --date=unix 2>/dev/null || echo 0)
else
  last_updated_at=0
fi

# Keep state/ across replace; drop everything else including .git
preserve="$tmp/preserve-state"
mkdir -p "$preserve"
if [[ -d "$NOS_PATH/state" ]]; then
  cp -a "$NOS_PATH/state/." "$preserve/" 2>/dev/null || true
fi

# Remove dirty git checkout entirely from the equation
rm -rf "$NOS_PATH"
mkdir -p "$NOS_PATH"
cp -a "$src"/. "$NOS_PATH"/
rm -rf "$NOS_PATH/.git"

mkdir -p "$NOS_PATH/state"
if [[ -d "$preserve" ]]; then
  cp -a "$preserve/." "$NOS_PATH/state/" 2>/dev/null || true
fi

cat >"$NOS_PATH/state/upstream" <<EOF
repo=${NOS_REPO}
ref=${NOS_REF}
synced_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

# Relink nos on PATH
mkdir -p "$HOME/.local/bin"
ln -sfn "$NOS_PATH/bin/nos" "$HOME/.local/bin/nos"
chmod +x "$NOS_PATH/bin/nos" 2>/dev/null || true

export NOS_PATH
echo "==> Running migrations after $last_updated_at..."
shopt -s nullglob
for file in "$NOS_PATH"/migrations/*.sh; do
  filename=$(basename "$file")
  migrate_at="${filename%.sh}"
  if [[ "$migrate_at" =~ ^[0-9]+$ ]] && (( migrate_at > last_updated_at )); then
    echo "=> migration $migrate_at"
    # shellcheck disable=SC1090
    source "$file" || echo "WARNING: migration $migrate_at failed (continuing)"
  fi
done
shopt -u nullglob

date +%s >"$NOS_PATH/state/updated-at"
rm -rf "$NOS_PATH/.git"

echo "==> Done. $NOS_PATH is a plain folder (no git)."
echo "    ref used: $NOS_REF"
command -v alacritty >/dev/null 2>&1 && echo "    OK: alacritty at $(command -v alacritty)" || echo "    NOTE: alacritty not on PATH yet"
echo "    Next updates:  nos update"
