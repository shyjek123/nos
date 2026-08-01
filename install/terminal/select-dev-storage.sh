#!/bin/bash

# Optional databases (default: none). Cybersec / low-level setups rarely need these.
if [[ -v NOS_FIRST_RUN_DBS ]]; then
	dbs=$NOS_FIRST_RUN_DBS
else
	AVAILABLE_DBS=("MySQL" "Redis" "PostgreSQL")
	dbs=$(gum choose "${AVAILABLE_DBS[@]}" --no-limit --height 5 --header "Select databases (optional, runs in Docker)")
fi

# Trim whitespace; treat empty / cancelled selection as "none"
dbs=$(echo "$dbs" | sed '/^$/d')
if [[ -z "$dbs" ]]; then
	echo "No databases selected — skipping Docker DB containers."
	return 0 2>/dev/null || true
fi

if ! sudo docker info >/dev/null 2>&1; then
	echo "WARNING: Docker is not running — skipping database containers."
	echo "Start Docker later, then re-run: source \"\$NOS_PATH/install/terminal/select-dev-storage.sh\""
	return 0 2>/dev/null || true
fi

while IFS= read -r db; do
	[[ -z "$db" ]] && continue
	case $db in
	MySQL)
		sudo docker run -d --restart unless-stopped -p "127.0.0.1:3306:3306" --name=mysql8 \
			-e MYSQL_ROOT_PASSWORD= -e MYSQL_ALLOW_EMPTY_PASSWORD=true mysql:8.4 \
			|| echo "WARNING: MySQL container failed to start"
		;;
	Redis)
		sudo docker run -d --restart unless-stopped -p "127.0.0.1:6379:6379" --name=redis redis:7 \
			|| echo "WARNING: Redis container failed to start"
		;;
	PostgreSQL)
		sudo docker run -d --restart unless-stopped -p "127.0.0.1:5432:5432" --name=postgres16 \
			-e POSTGRES_HOST_AUTH_METHOD=trust postgres:16 \
			|| echo "WARNING: PostgreSQL container failed to start"
		;;
	esac
done <<<"$dbs"
