#!/bin/bash

set -e

ascii_art='
═══════════════════════════════════════════════════════

███╗   ██╗███████╗██╗  ██╗████████╗
████╗  ██║██╔════╝╚██╗██╔╝╚══██╔══╝
██╔██╗ ██║█████╗   ╚███╔╝    ██║
██║╚██╗██║██╔══╝   ██╔██╗    ██║
██║ ╚████║███████╗██╔╝ ██╗   ██║
╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝   ╚═╝

                  O P E R A T I N G   S Y S T E M

═══════════════════════════════════════════════════════
'

echo -e "$ascii_art"
echo "=> NOS is for fresh Ubuntu 24.04+ installations only!"
echo -e "\nBegin installation (or abort with ctrl+c)..."

sudo apt-get update >/dev/null
sudo apt-get install -y curl ca-certificates tar git >/dev/null

NOS_INSTALL_DIR="${HOME}/.local/share/nos"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_REPO="https://github.com/shyjek123/nos"
NOS_REF="${NOS_REF:-main}"

rm -rf "$NOS_INSTALL_DIR"
mkdir -p "$(dirname "$NOS_INSTALL_DIR")" "$NOS_INSTALL_DIR"

install_from_archive() {
  local repo="${1%.git}"
  local ref="$2"
  local tmp src archive
  tmp=$(mktemp -d)
  archive="${repo}/archive/refs/heads/${ref}.tar.gz"
  echo "Downloading NOS from ${repo} (${ref})..."
  if ! curl -fsSL "$archive" -o "$tmp/nos.tar.gz"; then
    archive="${repo}/archive/refs/tags/${ref}.tar.gz"
    curl -fsSL "$archive" -o "$tmp/nos.tar.gz"
  fi
  mkdir -p "$tmp/extract"
  tar -xzf "$tmp/nos.tar.gz" -C "$tmp/extract"
  src=$(find "$tmp/extract" -mindepth 1 -maxdepth 1 -type d | head -n 1)
  cp -a "$src"/. "$NOS_INSTALL_DIR"/
  rm -rf "$NOS_INSTALL_DIR/.git" "$tmp"
}

# Install as a plain folder (no .git for the user to manage):
#   1. NOS_REPO set     → download that GitHub archive
#   2. Local checkout   → copy this tree, strip .git
#   3. Otherwise        → download DEFAULT_REPO archive
if [[ -n "${NOS_REPO:-}" ]]; then
  install_from_archive "$NOS_REPO" "$NOS_REF"
elif [[ -f "$SCRIPT_DIR/install.sh" && -d "$SCRIPT_DIR/install" && -d "$SCRIPT_DIR/themes" && -f "$SCRIPT_DIR/bin/nos" ]]; then
  echo "Installing NOS from local files at ${SCRIPT_DIR}..."
  cp -a "$SCRIPT_DIR"/. "$NOS_INSTALL_DIR"/
  rm -rf "$NOS_INSTALL_DIR/.git"
else
  install_from_archive "$DEFAULT_REPO" "$NOS_REF"
fi

if [[ ! -f "$NOS_INSTALL_DIR/install.sh" ]]; then
  echo "ERROR: install.sh not found in $NOS_INSTALL_DIR"
  echo "Run from a full local checkout, or set NOS_REPO:"
  echo "  cd /path/to/nos && bash boot.sh"
  echo "  NOS_REPO=https://github.com/shyjek123/nos bash boot.sh"
  exit 1
fi

mkdir -p "$NOS_INSTALL_DIR/state"
# Fresh install: stamp "now" so historical migrations are skipped on first update
date +%s >"$NOS_INSTALL_DIR/state/updated-at"
cat >"$NOS_INSTALL_DIR/state/upstream" <<EOF
repo=${NOS_REPO:-$DEFAULT_REPO}
ref=${NOS_REF}
synced_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

echo "Installation starting..."
export NOS_PATH="$NOS_INSTALL_DIR"
# shellcheck disable=SC1091
source "$NOS_PATH/install.sh"
