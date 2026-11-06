#!/bin/bash

# Refresh bash prompt: cwd + git branch (load order fixed after mise/zoxide)
echo "Updating bash prompt (cwd + git)..."
# No copy needed — ~/.bashrc sources ~/.local/share/nos/defaults/bash/rc live.
# Open a new shell / Alt+t to pick it up.
echo "New terminals show: ~/path (branch) ❯"
