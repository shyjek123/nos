#!/bin/bash

# Shared return path for NOS submenus.
# - Direct CLI (e.g. `nos update`): leave the app and return to the shell
# - Interactive TUI: show the main menu again (without re-running a subcommand)

if [[ "${NOS_FROM_CLI:-}" == "1" ]]; then
  # shellcheck disable=SC1091
  source "$NOS_PATH/bin/nos-sub/exit-nos.sh"
  return 0 2>/dev/null || exit 0
fi

# Clear inherited positional args so `nos update` cannot loop forever
set --
clear
# shellcheck disable=SC1091
source "$NOS_PATH/bin/nos-sub/header.sh"
# shellcheck disable=SC1091
source "$NOS_PATH/bin/nos-sub/menu.sh"
