#!/bin/bash

sudo echo "Running upgrade migration..."

# Add rustc and pgsql client libs
source $NOS_PATH/install/terminal/libraries.sh

# Refresh desktop launchers that still ship with NOS
source $NOS_PATH/applications/About.sh
source $NOS_PATH/applications/Activity.sh
source $NOS_PATH/applications/Docker.sh
source $NOS_PATH/applications/Neovim.sh
source $NOS_PATH/applications/Nos.sh
