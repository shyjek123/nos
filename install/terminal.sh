#!/bin/bash

# Needed for all installers
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl git unzip wget bash-completion

# Run terminal installers; one failure must not abort the rest of NOS
for installer in "$NOS_PATH"/install/terminal/*.sh; do
  echo "=> $(basename "$installer")"
  # shellcheck disable=SC1090
  if ! source "$installer"; then
    echo "WARNING: $(basename "$installer") failed — continuing install."
  fi
done
