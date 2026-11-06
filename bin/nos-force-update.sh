#!/bin/bash

# Force-refresh ~/.local/share/nos from GitHub with no git pull / commit / stash.
# Safe to download and run even when the install dir is a dirty git checkout.
#
#   curl -fsSL https://raw.githubusercontent.com/shyjek123/nos/main/bin/nos-force-update.sh | bash
#   NOS_REF=cursor/fix-black-screen-2ef7 curl -fsSL \
#     https://raw.githubusercontent.com/shyjek123/nos/refs/heads/cursor/fix-black-screen-2ef7/bin/nos-force-update.sh | bash

set -euo pipefail

NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"
NOS_REF="${NOS_REF:-main}"
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

mkdir -p "$NOS_PATH/state"

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
cp -a "$NOS_PATH/state" "$preserve" 2>/dev/null || mkdir -p "$preserve"

# Remove dirty git checkout entirely from the equation
rm -rf "$NOS_PATH"
mkdir -p "$NOS_PATH"
cp -a "$src"/. "$NOS_PATH"/
rm -rf "$NOS_PATH/.git"

rm -rf "$NOS_PATH/state"
cp -a "$preserve" "$NOS_PATH/state"

cat >"$NOS_PATH/state/upstream" <<EOF
repo=${NOS_REPO}
ref=${NOS_REF}
synced_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

# Relink nos on PATH
if [[ -f "$NOS_PATH/install/terminal/zz-nos-tui.sh" ]]; then
  # shellcheck disable=SC1091
  source "$NOS_PATH/install/terminal/zz-nos-tui.sh"
fi

export NOS_PATH
echo "==> Running migrations after $last_updated_at..."
shopt -s nullglob
for file in "$NOS_PATH"/migrations/*.sh; do
  filename=$(basename "$file")
  migrate_at="${filename%.sh}"
  if [[ "$migrate_at" =~ ^[0-9]+$ ]] && (( migrate_at > last_updated_at )); then
    echo "=> migration $migrate_at"
    # shellcheck disable=SC1090
    source "$file"
  fi
done
shopt -u nullglob

date +%s >"$NOS_PATH/state/updated-at"
rm -rf "$NOS_PATH/.git"

# Always enforce Alacritty default + remove Ghostty after refresh
if [[ -f "$NOS_PATH/install/desktop/ensure-alacritty-default.sh" ]]; then
  echo "==> Applying Alacritty default / removing Ghostty..."
  # shellcheck disable=SC1091
  source "$NOS_PATH/install/desktop/ensure-alacritty-default.sh"
else
  echo "WARNING: ensure-alacritty-default.sh missing from archive (wrong NOS_REF?)."
  echo "         Re-run with: NOS_REF=cursor/fix-black-screen-2ef7 ..."
fi

echo "==> Done. $NOS_PATH is a plain folder (no git)."
test -f "$NOS_PATH/install/desktop/ensure-alacritty-default.sh" && echo "    OK: ensure-alacritty-default.sh present"
echo "    Next updates:  nos update"
