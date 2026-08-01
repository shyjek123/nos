#!/bin/bash

# Ghidra — NSA reverse-engineering suite (needs Java; libraries.sh installs JDK)
set -e

GHIDRA_DIR="${GHIDRA_DIR:-$HOME/.local/share/ghidra}"
mkdir -p "$HOME/.local/share" "$HOME/.local/bin"

# Resolve latest GitHub release asset (linux x64 zip)
RELEASE_JSON=$(curl -fsSL https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest)
GHIDRA_URL=$(echo "$RELEASE_JSON" | grep -Po '"browser_download_url": "\K[^"]+_PUBLIC_[^"]+_linux_x86_64\.zip' | head -1)

if [[ -z "$GHIDRA_URL" ]]; then
  # Fallback pattern without _linux_x86_64 suffix (older releases)
  GHIDRA_URL=$(echo "$RELEASE_JSON" | grep -Po '"browser_download_url": "\K[^"]+_PUBLIC_[^"]+\.zip' | head -1)
fi

if [[ -z "$GHIDRA_URL" ]]; then
  echo "Could not resolve Ghidra download URL"
  exit 1
fi

cd /tmp
wget -O ghidra.zip "$GHIDRA_URL"
rm -rf "$GHIDRA_DIR"
mkdir -p "$GHIDRA_DIR"
unzip -q ghidra.zip -d /tmp/ghidra-extract
# Zip contains a single top-level directory
EXTRACTED=$(find /tmp/ghidra-extract -mindepth 1 -maxdepth 1 -type d | head -1)
mv "$EXTRACTED"/* "$GHIDRA_DIR"/
rm -rf ghidra.zip /tmp/ghidra-extract
cd -

ln -sfn "$GHIDRA_DIR/ghidraRun" "$HOME/.local/bin/ghidra"

# Desktop launcher
cat <<EOF >~/.local/share/applications/Ghidra.desktop
[Desktop Entry]
Version=1.0
Name=Ghidra
Comment=Software reverse engineering suite
Exec=$HOME/.local/bin/ghidra
Terminal=false
Type=Application
Icon=applications-science
Categories=Development;Debugger;
StartupNotify=true
EOF

echo "Ghidra installed. Launch with: ghidra"
