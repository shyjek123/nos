#!/bin/bash

# Strip leftover desktop extras, keep snap packages, and put LibreOffice back.

NOS_PATH="${NOS_PATH:-$HOME/.local/share/nos}"

# shellcheck disable=SC1091
source "$NOS_PATH/install/desktop/a-remove-ubuntu-bloat.sh"
# shellcheck disable=SC1091
source "$NOS_PATH/install/desktop/app-libreoffice.sh"
