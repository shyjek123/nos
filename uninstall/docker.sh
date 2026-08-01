#!/bin/bash

sudo apt purge --auto-remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras || true
sudo gpasswd -d "$USER" docker 2>/dev/null || true
sudo groupdel docker 2>/dev/null || true
