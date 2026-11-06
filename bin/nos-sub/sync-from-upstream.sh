#!/bin/bash

# Refresh $NOS_PATH from upstream as a plain folder (never leave a .git checkout).
# Intended to be executed (bash path/to/sync-from-upstream.sh), not sourced.
# Env:
#   NOS_PATH  — install dir (default: ~/.local/share/nos)
#   NOS_REPO  — https://github.com/owner/repo[.git] (default: shyjek123/nos)
#   NOS_REF   — branch or tag (default: main)

set -euo pipefail

NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"
NOS_REF="${NOS_REF:-main}"
NOS_REPO_RAW="${NOS_REPO:-https://github.com/shyjek123/nos}"

NOS_REPO_URL="${NOS_REPO_RAW%.git}"
NOS_REPO_URL="${NOS_REPO_URL%/}"

state_dir="$NOS_PATH/state"
mkdir -p "$NOS_PATH" "$state_dir"

tmp=$(mktemp -d)
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT

echo "Downloading NOS (${NOS_REF})..."

archive_url="${NOS_REPO_URL}/archive/refs/heads/${NOS_REF}.tar.gz"
tag_archive_url="${NOS_REPO_URL}/archive/refs/tags/${NOS_REF}.tar.gz"

if ! curl -fsSL "$archive_url" -o "$tmp/nos.tar.gz" 2>/dev/null; then
  if ! curl -fsSL "$tag_archive_url" -o "$tmp/nos.tar.gz" 2>/dev/null; then
    echo "ERROR: could not download $archive_url"
    echo "Set NOS_REPO / NOS_REF, or check your network."
    exit 1
  fi
fi

mkdir -p "$tmp/extract"
tar -xzf "$tmp/nos.tar.gz" -C "$tmp/extract"
src=$(find "$tmp/extract" -mindepth 1 -maxdepth 1 -type d | head -n 1)

if [[ -z "$src" || ! -f "$src/install.sh" ]]; then
  echo "ERROR: downloaded archive did not contain install.sh"
  exit 1
fi

# Preserve local state across replace
preserve="$tmp/preserve"
mkdir -p "$preserve"
if [[ -d "$state_dir" ]]; then
  cp -a "$state_dir" "$preserve/state"
fi

# Replace tree but keep state/
find "$NOS_PATH" -mindepth 1 -maxdepth 1 ! -name state -exec rm -rf {} +
cp -a "$src"/. "$NOS_PATH"/

if [[ -d "$preserve/state" ]]; then
  rm -rf "$NOS_PATH/state"
  cp -a "$preserve/state" "$NOS_PATH/state"
fi

rm -rf "$NOS_PATH/.git"

cat >"$NOS_PATH/state/upstream" <<EOF
repo=${NOS_REPO_URL}
ref=${NOS_REF}
synced_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

echo "NOS files synced to $NOS_PATH (plain folder, not a git repo)."
