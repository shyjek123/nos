#!/bin/bash

CHOICES=(
  "NOS               Remove NOS config, launchers, and ~/.local/share/nos"
  "Alacritty         Fallback terminal"
  "Cursor            AI code editor"
  "Docker            Docker Engine + LazyDocker launcher"
  "Dev Language      Uninstall selected programming languages"
  "Firefox           Default browser"
  "Ghostty           Default terminal"
  "Ghidra            Reverse-engineering suite"
  "GitHub CLI        gh"
  "Joplin            Notes (Alt+n)"
  "LocalSend         LAN file sharing"
  "Neovim            Terminal editor + config"
  "Ollama            Local LLMs"
  "1password         Password manager"
  "Signal            Private messaging"
  "Tailscale         Mesh VPN"
  "VirtualBox        VMs"
  "VSCode            Code editor"
  "Web Apps          Chat GPT / Tailscale web launchers"
  "Zellij            Terminal multiplexer"
  "<< Back           "
)

CHOICE=$(gum choose "${CHOICES[@]}" --height 22 --header "Uninstall")

if [[ "$CHOICE" == "<< Back"* ]] || [[ -z "$CHOICE" ]]; then
  echo ""
else
  INSTALLER=$(echo "$CHOICE" | awk -F ' {2,}' '{print $1}' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

  case "$INSTALLER" in
  "nos") UNINSTALLER_FILE="$NOS_PATH/uninstall/nos.sh" ;;
  "dev-language") UNINSTALLER_FILE="$NOS_PATH/uninstall/dev-language.sh" ;;
  "web-apps") UNINSTALLER_FILE="$NOS_PATH/uninstall/select-web-apps.sh" ;;
  "docker") UNINSTALLER_FILE="$NOS_PATH/uninstall/docker.sh" ;;
  "github-cli") UNINSTALLER_FILE="$NOS_PATH/uninstall/app-github-cli.sh" ;;
  "1password") UNINSTALLER_FILE="$NOS_PATH/uninstall/app-1password.sh" ;;
  *) UNINSTALLER_FILE="$NOS_PATH/uninstall/app-$INSTALLER.sh" ;;
  esac

  if [[ ! -f "$UNINSTALLER_FILE" ]]; then
    echo "No uninstaller: $UNINSTALLER_FILE"
  else
    if gum confirm "Run uninstaller for $INSTALLER?"; then
      # shellcheck disable=SC1090
      source "$UNINSTALLER_FILE"
      if [[ "${NOS_UNINSTALLED:-}" == "1" ]]; then
        clear
        echo "NOS has been removed. Close this terminal or open a new shell."
        exit 0
      fi
      gum spin --spinner globe --title "Uninstall completed!" -- sleep 3
    fi
  fi
fi

clear
source "$NOS_PATH/bin/nos"
