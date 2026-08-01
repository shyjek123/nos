#!/bin/bash

source $NOS_PATH/defaults/bash/functions

AVAILABLE_WEB_APPS=("Chat GPT" "Tailscale")
apps=$(gum choose "${AVAILABLE_WEB_APPS[@]}" --no-limit --height 4 --header "Select web apps to uninstall")

if [[ -n "$apps" ]]; then
  IFS=$'\n'
  for app in $apps; do
    case $app in
    "Chat GPT")
      web2app-remove 'Chat GPT'
      app2folder-remove 'Chat GPT.desktop' WebApps
      ;;
    "Tailscale")
      web2app-remove 'Tailscale'
      app2folder-remove 'Tailscale.desktop' WebApps
      ;;
    esac
  done
fi
