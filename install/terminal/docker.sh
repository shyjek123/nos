#!/bin/bash

# Add the official Docker repo (suite = Ubuntu codename; fall back if Docker lags a new LTS)
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
	[ -f /etc/apt/keyrings/docker.asc ] && sudo rm /etc/apt/keyrings/docker.asc
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo wget -qO /etc/apt/keyrings/docker.asc https://download.docker.com/linux/ubuntu/gpg
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	. /etc/os-release
	DOCKER_SUITE="${VERSION_CODENAME}"
	ARCH="$(dpkg --print-architecture)"
	if ! curl -fsI "https://download.docker.com/linux/ubuntu/dists/${DOCKER_SUITE}/stable/binary-${ARCH}/Packages" >/dev/null 2>&1; then
		echo "WARNING: Docker CE has no '${DOCKER_SUITE}' suite yet — falling back to 'noble'"
		DOCKER_SUITE="noble"
	fi

	echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${DOCKER_SUITE} stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
fi

# Install Docker engine and standard plugins
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

# Give this user privileged Docker access (takes effect on next login)
sudo usermod -aG docker "${USER}"

# Ensure the daemon is running for the rest of install (sudo works without re-login)
sudo systemctl enable --now docker 2>/dev/null || sudo service docker start 2>/dev/null || true

# Limit log size to avoid running out of disk
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json >/dev/null
# Reload if daemon.json changed while docker was already running
sudo systemctl reload docker 2>/dev/null || sudo service docker restart 2>/dev/null || true
