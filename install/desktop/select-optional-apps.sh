#!/bin/bash

if [[ -v NOS_FIRST_RUN_OPTIONAL_APPS ]]; then
	apps=$NOS_FIRST_RUN_OPTIONAL_APPS

	if [[ -n "$apps" ]]; then
		for app in $apps; do
			source "$NOS_PATH/install/desktop/optional/app-${app,,}.sh"
		done
	fi
fi
