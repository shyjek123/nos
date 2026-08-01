#!/bin/bash

CHOICES=(
  "Cursor            Install Cursor AI code editor"
  "Dev Language      Install programming language environment"
  "Dev Database      Install development database in Docker"
  "GitHub Projects   Authenticate with gh and clone all repos into ~/projects"
  "1password         Manage your passwords securely across devices"
  "ASDControl        Set brightness on Apple Studio and XDR displays"
  "Ghidra            NSA reverse-engineering suite"
  "LocalSend         Share files over the local network"
  "Mainline Kernels  Install newer Linux kernels than Ubuntu defaults"
  "Ollama            Run LLMs, like Meta's Llama3, locally"
  "Signal            Private messaging"
  "Tailscale         Mesh VPN based on WireGuard and with Magic DNS"
  "VirtualBox        Virtual machines to run Windows/Linux"
  "Web Apps          Install web apps with their own icon and shell"
  "> All             Re-run any of the default installers"
  "<< Back           "
)

CHOICE=$(gum choose "${CHOICES[@]}" --height 20 --header "Install application")

if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
  # Don't install anything
  echo ""
elif [[ "$CHOICE" == "> All"* ]]; then
  INSTALLER_FILE=$(gum file "$NOS_PATH/install")

  [[ -n "$INSTALLER_FILE" ]] &&
    gum confirm "Run installer?" &&
    source "$INSTALLER_FILE" &&
    gum spin --spinner globe --title "Install completed!" -- sleep 3
else
  INSTALLER=$(echo "$CHOICE" | awk -F ' {2,}' '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

  case "$INSTALLER" in
  "cursor") INSTALLER_FILE="$NOS_PATH/bin/nos-sub/install-dev-editor.sh" ;;
  "web-apps") INSTALLER_FILE="$NOS_PATH/install/desktop/optional/select-web-apps.sh" ;;
  "dev-language") INSTALLER_FILE="$NOS_PATH/install/terminal/select-dev-language.sh" ;;
  "dev-database") INSTALLER_FILE="$NOS_PATH/install/terminal/select-dev-storage.sh" ;;
  "github-projects") INSTALLER_FILE="$NOS_PATH/install/terminal/z-clone-github-projects.sh" ;;
  "ollama") INSTALLER_FILE="$NOS_PATH/install/terminal/optional/app-ollama.sh" ;;
  "tailscale") INSTALLER_FILE="$NOS_PATH/install/terminal/optional/app-tailscale.sh" ;;
  "ghidra") INSTALLER_FILE="$NOS_PATH/install/desktop/optional/app-ghidra.sh" ;;
  "localsend") INSTALLER_FILE="$NOS_PATH/install/desktop/optional/app-localsend.sh" ;;
  "signal") INSTALLER_FILE="$NOS_PATH/install/desktop/optional/app-signal.sh" ;;
  *) INSTALLER_FILE="$NOS_PATH/install/desktop/optional/app-$INSTALLER.sh" ;;
  esac

  if [[ ! -f "$INSTALLER_FILE" ]]; then
    echo "No installer: $INSTALLER_FILE"
  else
    # shellcheck disable=SC1090
    source "$INSTALLER_FILE" && gum spin --spinner globe --title "Install completed!" -- sleep 3
  fi
fi

clear
source "$NOS_PATH/bin/nos"
