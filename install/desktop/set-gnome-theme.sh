#!/bin/bash

source "$NOS_PATH/themes/velocity/gnome.sh"
# TopHat may be skipped if the user declined extension install
source "$NOS_PATH/themes/velocity/tophat.sh" 2>/dev/null || true
