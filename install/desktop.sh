#!/bin/bash

# Run desktop installers; one failure must not abort the rest of NOS
for installer in "$NOS_PATH"/install/desktop/*.sh; do
  echo "=> $(basename "$installer")"
  # shellcheck disable=SC1090
  if ! source "$installer"; then
    echo "WARNING: $(basename "$installer") failed — continuing install."
  fi
done

# Logout to pickup changes
gum confirm "Ready to reboot for all settings to take effect?" && sudo reboot || true
