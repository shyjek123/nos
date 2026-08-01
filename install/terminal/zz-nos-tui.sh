#!/bin/bash

# Ensure `nos` is on PATH via ~/.local/bin (in addition to $NOS_PATH/bin)
mkdir -p "$HOME/.local/bin"
ln -sfn "$NOS_PATH/bin/nos" "$HOME/.local/bin/nos"
chmod +x "$NOS_PATH/bin/nos"

# Desktop launcher for the TUI
source "$NOS_PATH/applications/Nos.sh"
