#!/bin/bash

shopt -s nullglob
for script in "$NOS_PATH/applications"/*.sh; do
  # shellcheck disable=SC1090
  source "$script"
done
