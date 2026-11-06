#!/bin/bash

if [ $# -eq 0 ]; then
	SUB=$(gum choose \
		"Theme" \
		"Font" \
		"Install" \
		"Uninstall" \
		"Update" \
		"Help" \
		"Exit" \
		--height 10 \
		--header "NOS — manage themes & apps" | tr '[:upper:]' '[:lower:]')
else
	SUB=$1
fi

# Aliases for convenience
case "$SUB" in
themes) SUB="theme" ;;
apps | app) SUB="install" ;;
remove) SUB="uninstall" ;;
manual) SUB="help" ;;
quit) SUB="exit" ;;
esac

# Empty selection (Esc/Ctrl+C) or Exit → leave NOS with a clean screen
if [[ -z "$SUB" || "$SUB" == "exit" ]]; then
	# shellcheck disable=SC1091
	source "$NOS_PATH/bin/nos-sub/exit-nos.sh"
	return 0 2>/dev/null || exit 0
fi

# shellcheck disable=SC1090
source "$NOS_PATH/bin/nos-sub/$SUB.sh"
