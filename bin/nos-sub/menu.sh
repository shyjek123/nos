#!/bin/bash

if [ $# -eq 0 ]; then
	SUB=$(gum choose \
		"Theme" \
		"Font" \
		"Install" \
		"Uninstall" \
		"Update" \
		"Help" \
		"Quit" \
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
esac

[ -n "$SUB" ] && [ "$SUB" != "quit" ] && source "$NOS_PATH/bin/nos-sub/$SUB.sh"
