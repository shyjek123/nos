#!/bin/bash

gum style --border rounded --padding "0 2" --border-foreground 51 \
	"NOS command center" \
	"" \
	"Invoke anytime from a terminal:" \
	"  nos                 open this menu (Exit to leave)" \
	"  nos theme           switch themes" \
	"  nos install         install apps / languages / GitHub projects" \
	"  nos uninstall       remove apps or NOS itself" \
	"  nos font            change terminal font" \
	"  nos update          update NOS / terminal tools (then exits)" \
	"" \
	"If the desktop is black after install, from a TTY (Ctrl+Alt+F3):" \
	"  bash ~/.local/share/nos/bin/recover-desktop.sh --reboot" \
	"" \
	"Install root: $NOS_PATH  (plain folder; nos update syncs it)" \
	"Projects dir: ${NOS_PROJECTS_DIR:-$HOME/projects}" \
	"Your git projects stay under ~/projects — not inside NOS." \

echo
if [[ "${NOS_FROM_CLI:-}" == "1" ]]; then
	gum confirm "Exit NOS?" && return 0 || true
	return 0
fi
if gum confirm "Back to menu?"; then
	# shellcheck disable=SC1091
	source "$NOS_PATH/bin/nos-sub/return.sh"
fi
