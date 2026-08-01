#!/bin/bash

gum style --border rounded --padding "0 2" --border-foreground 51 \
	"NOS command center" \
	"" \
	"Invoke anytime from a terminal:" \
	"  nos                 open this menu" \
	"  nos theme           switch themes" \
	"  nos install         install apps / languages / GitHub projects" \
	"  nos uninstall       remove apps or NOS itself" \
	"  nos font            change terminal font" \
	"  nos update          update NOS / terminal tools" \
	"" \
	"If the desktop is black after install, from a TTY (Ctrl+Alt+F3):" \
	"  bash ~/.local/share/nos/bin/recover-desktop.sh --reboot" \
	"" \
	"Install root: $NOS_PATH" \
	"Projects dir: ${NOS_PROJECTS_DIR:-$HOME/projects}"

echo
gum confirm "Back to menu?" && source "$NOS_PATH/bin/nos-sub/menu.sh" || true
