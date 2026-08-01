#!/bin/bash

# Only ask for default desktop app choices when running Gnome
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  OPTIONAL_APPS=("1password" "Ghidra" "Signal" "LocalSend")
  DEFAULT_OPTIONAL_APPS='1password,Ghidra'
  export NOS_FIRST_RUN_OPTIONAL_APPS=$(gum choose "${OPTIONAL_APPS[@]}" --no-limit --selected $DEFAULT_OPTIONAL_APPS --height 6 --header "Select optional apps" | tr ' ' '-')
fi

AVAILABLE_LANGUAGES=("C/C++" "Zig" "Odin" "Rust" "Python" "Go" "Node.js" "Java" "PHP")
SELECTED_LANGUAGES="C/C++,Rust,Python,Go"
export NOS_FIRST_RUN_LANGUAGES=$(gum choose "${AVAILABLE_LANGUAGES[@]}" --no-limit --selected "$SELECTED_LANGUAGES" --height 10 --header "Select programming languages")

AVAILABLE_DBS=("MySQL" "Redis" "PostgreSQL")
# Default: none (Docker DBs are optional; a failed docker run must not abort install)
export NOS_FIRST_RUN_DBS=$(gum choose "${AVAILABLE_DBS[@]}" --no-limit --height 5 --header "Select databases (optional, runs in Docker)")
