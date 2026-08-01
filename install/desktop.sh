#!/bin/bash

# Run desktop installers
for installer in "$NOS_PATH"/install/desktop/*.sh; do
  # shellcheck disable=SC1090
  source "$installer"
done

# Logout to pickup changes
gum confirm "Ready to reboot for all settings to take effect?" && sudo reboot || true
