#!/bin/bash

# Cybersecurity tools for a first NOS install.
# Package names checked against Ubuntu 24.04 apt. One install, nothing else.

export DEBIAN_FRONTEND=noninteractive

# Wireshark asks a setuid question unless this is answered first.
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections 2>/dev/null || true

sudo apt update -y

sudo apt install -y \
  aircrack-ng \
  afflib-tools \
  androguard \
  apktool \
  arp-scan \
  autopsy \
  bettercap \
  binwalk \
  bully \
  cadaver \
  cewl \
  checksec \
  chkrootkit \
  cifs-utils \
  cowpatty \
  crunch \
  cupp \
  dc3dd \
  dcfldd \
  dirb \
  dirsearch \
  dnsrecon \
  dnsutils \
  dsniff \
  ettercap-graphical \
  ewf-tools \
  fcrackzip \
  ffuf \
  fierce \
  foremost \
  gobuster \
  hashcat \
  hashdeep \
  hashid \
  hexedit \
  hostapd \
  hping3 \
  hydra \
  ike-scan \
  john \
  jq \
  ldap-utils \
  libimage-exiftool-perl \
  lynis \
  macchanger \
  maskprocessor \
  masscan \
  mdk3 \
  mdk4 \
  medusa \
  mitmproxy \
  nasm \
  nbtscan \
  ncat \
  ncrack \
  netcat-openbsd \
  netdiscover \
  netsniff-ng \
  nfs-common \
  ngrep \
  nikto \
  nmap \
  onesixtyone \
  ophcrack \
  outguess \
  patator \
  patchelf \
  pdfcrack \
  pixiewps \
  proxychains4 \
  python3-impacket \
  python3-pwntools \
  python3-scapy \
  radare2 \
  rarcrack \
  reaver \
  rkhunter \
  rlwrap \
  rpcbind \
  samba-common-bin \
  scalpel \
  sleuthkit \
  smbclient \
  smbmap \
  snmp \
  socat \
  sqlmap \
  ssdeep \
  sslscan \
  stegseek \
  steghide \
  stegsnow \
  tcpdump \
  tcpflow \
  tcpreplay \
  testdisk \
  testssl.sh \
  thc-ipv6 \
  tor \
  torsocks \
  traceroute \
  tshark \
  wapiti \
  wfuzz \
  whatweb \
  whois \
  wifite \
  wireshark \
  xxd \
  yara \
  yasm \
  zmap

sudo dpkg-reconfigure -f noninteractive wireshark-common 2>/dev/null || true
sudo usermod -aG wireshark "$USER" 2>/dev/null || true
