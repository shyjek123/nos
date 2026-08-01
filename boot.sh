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
sudo apt-get install -y git >/dev/null

NOS_INSTALL_DIR="${HOME}/.local/share/nos"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_REPO="https://github.com/shyjek123/nos.git"

# Install source resolution:
#   1. NOS_REPO set     → clone that remote
#   2. Local checkout   → copy this tree into ~/.local/share/nos
#   3. Otherwise        → clone DEFAULT_REPO
rm -rf "$NOS_INSTALL_DIR"

if [[ -n "${NOS_REPO:-}" ]]; then
	echo "Cloning NOS from ${NOS_REPO}..."
	git clone "$NOS_REPO" "$NOS_INSTALL_DIR" >/dev/null
	if [[ ${NOS_REF:-main} != "master" ]]; then
		cd "$NOS_INSTALL_DIR"
		git fetch origin "${NOS_REF:-main}" && git checkout "${NOS_REF:-main}"
		cd -
	fi
elif [[ -f "$SCRIPT_DIR/install.sh" && -d "$SCRIPT_DIR/install" && -d "$SCRIPT_DIR/themes" ]]; then
	echo "Using local NOS checkout at ${SCRIPT_DIR}..."
	mkdir -p "$(dirname "$NOS_INSTALL_DIR")"
	cp -a "$SCRIPT_DIR" "$NOS_INSTALL_DIR"
else
	echo "Cloning NOS from ${DEFAULT_REPO}..."
	git clone "$DEFAULT_REPO" "$NOS_INSTALL_DIR" >/dev/null
	if [[ ${NOS_REF:-main} != "master" ]]; then
		cd "$NOS_INSTALL_DIR"
		git fetch origin "${NOS_REF:-main}" && git checkout "${NOS_REF:-main}" || true
		cd -
	fi
fi

if [[ ! -f "$NOS_INSTALL_DIR/install.sh" ]]; then
	echo "ERROR: install.sh not found in $NOS_INSTALL_DIR"
	echo "Your GitHub repo may be empty / out of date."
	echo "Run boot.sh from a full local checkout, or push your code first:"
	echo "  cd /path/to/nos && bash boot.sh"
	exit 1
fi

echo "Installation starting..."
export NOS_PATH="$NOS_INSTALL_DIR"
source "$NOS_PATH/install.sh"
