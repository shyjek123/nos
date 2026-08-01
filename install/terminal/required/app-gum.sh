#!/bin/bash

# Gum is used for the NOS commands for tailoring NOS after the initial install
sudo apt-get update -y >/dev/null
sudo apt-get install -y curl ca-certificates >/dev/null

cd /tmp
GUM_VERSION="0.17.0"
curl -fsSL -o gum.deb "https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_amd64.deb"
sudo apt-get install -y --allow-downgrades ./gum.deb
rm gum.deb
cd -
