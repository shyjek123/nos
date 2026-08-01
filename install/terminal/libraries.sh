#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

sudo apt install -y \
  rustc pipx libreadline-dev zlib1g-dev libyaml-dev libreadline-dev libncurses5-dev \
  libffi-dev libgdbm-dev libjemalloc2 libvips imagemagick libmagickwand-dev mupdf mupdf-tools \
  redis-tools sqlite3 libsqlite3-0 libmysqlclient-dev libpq-dev postgresql-client \
  postgresql-client-common

# Core build + reverse-engineering / pentest tooling for NOS

# Preseed Wireshark setuid before package install
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections 2>/dev/null || true

sudo apt install -y \
  build-essential pkg-config autoconf bison clang cmake ninja-build nasm yasm \
  libssl-dev libffi-dev zlib1g-dev libpcap-dev libnetfilter-queue-dev \
  gdb gdb-multiarch lldb valgrind \
  strace ltrace \
  binutils binwalk hexedit xxd \
  radare2 \
  nmap ncat masscan \
  wireshark tshark tcpdump \
  netcat-openbsd socat \
  jq whois dnsutils traceroute \
  hydra john hashcat \
  sqlmap \
  aircrack-ng \
  smbclient nfs-common \
  qemu-system-x86 qemu-user qemu-user-static \
  patchelf checksec \
  python3-pip python3-venv pipx \
  openjdk-21-jdk \
  foremost testdisk \
  steghide exiftool \
  apktool \
  gobuster ffuf \
  nikto \
  proxychains4 \
  rlwrap

# Wireshark: allow non-root capture when possible
sudo dpkg-reconfigure -f noninteractive wireshark-common 2>/dev/null || true
sudo usermod -aG wireshark "$USER" 2>/dev/null || true

# Ensure pipx path for user tools
pipx ensurepath >/dev/null 2>&1 || true

# Python RE / exploit helpers
pipx install pwntools || true
pipx install ropper || true
pipx install ropgadget || true

# pwndbg — exploit development / RE GDB frontend
# Provides the `pwndbg` command; see https://pwndbg.re/stable/setup/
if ! command -v pwndbg &>/dev/null; then
  if curl --proto '=https' --tlsv1.2 -LsSf 'https://install.pwndbg.re' | sh -s -- -t pwndbg-gdb; then
    echo "pwndbg installed."
  else
    echo "WARNING: pwndbg install failed — re-run later or see https://pwndbg.re/stable/setup/"
  fi
fi
if ! command -v pwndbg &>/dev/null; then
  echo "WARNING: pwndbg not on PATH yet (open a new shell after install)."
fi

# Personal GDB defaults land at ~/.gdbinit on the installed OS
if [ -f "$HOME/.gdbinit" ] && ! cmp -s "$HOME/.gdbinit" ~/.local/share/nos/configs/.gdbinit 2>/dev/null; then
  cp "$HOME/.gdbinit" "$HOME/.gdbinit.bak"
fi
cp ~/.local/share/nos/configs/.gdbinit "$HOME/.gdbinit"
