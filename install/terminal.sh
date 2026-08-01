#!/bin/bash

# Needed for all installers
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl git unzip wget bash-completion

# Run terminal installers
for installer in "$NOS_PATH"/install/terminal/*.sh; do
  # shellcheck disable=SC1090
  source "$installer"
done
