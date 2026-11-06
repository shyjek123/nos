#!/bin/bash

CHOICES=(
	"NOS           Update NOS itself and run any migrations"
	"Ollama        Run LLMs, like Meta's Llama3, locally"
	"LazyGit       TUI for Git"
	"LazyDocker    TUI for Docker"
	"Neovim        Text editor that runs in the terminal"
	"Zellij        Adds panes, tabs, and sessions to the terminal"
	"<< Back       "
	"Exit          Leave NOS"
)

CHOICE=$(gum choose "${CHOICES[@]}" --height 12 --header "Update manually-managed applications")

if [[ -z "$CHOICE" || "$CHOICE" == "Exit"* ]]; then
	return 0 2>/dev/null || exit 0
elif [[ "$CHOICE" == "<< Back"* ]]; then
	:
else
	INSTALLER=$(echo "$CHOICE" | awk -F ' {2,}' '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

	case "$INSTALLER" in
	"nos") INSTALLER_FILE="$NOS_PATH/bin/nos-sub/migrate.sh" ;;
	"ollama") INSTALLER_FILE="$NOS_PATH/install/terminal/optional/app-ollama.sh" ;;
	*) INSTALLER_FILE="$NOS_PATH/install/terminal/app-$INSTALLER.sh" ;;
	esac

	if [[ ! -f "$INSTALLER_FILE" ]]; then
		echo "No updater: $INSTALLER_FILE"
	else
		# shellcheck disable=SC1090
		source "$INSTALLER_FILE" && gum spin --spinner globe --title "Update completed!" -- sleep 3
	fi
fi

# shellcheck disable=SC1091
source "$NOS_PATH/bin/nos-sub/return.sh"
