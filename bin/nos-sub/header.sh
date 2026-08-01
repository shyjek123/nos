#!/bin/bash

source "$NOS_PATH/ascii.sh"
echo "" # Add spacing
if [[ -f "$NOS_PATH/version" ]]; then
  echo "                                 $(cat "$NOS_PATH/version")"
else
  echo "                                 NOS"
fi
echo "" # Add spacing
