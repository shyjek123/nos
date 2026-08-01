#!/bin/bash

# Install only the optional desktop apps chosen during first-run
# (or leave unset when re-running desktop installers later).
if [[ -v NOS_FIRST_RUN_OPTIONAL_APPS ]]; then
	apps=$NOS_FIRST_RUN_OPTIONAL_APPS

	if [[ -n "$apps" ]]; then
		for app in $apps; do
			installer="$NOS_PATH/install/desktop/optional/app-${app,,}.sh"
			if [[ -f "$installer" ]]; then
				# shellcheck disable=SC1090
				source "$installer"
			else
				echo "WARNING: No optional installer for '$app' ($installer)"
			fi
		done
	fi
fi
