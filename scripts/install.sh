#!/bin/bash
if [[ $EUID -ne 0 ]]; then echo "Run as root: sudo bash scripts/install.sh"; exit 1; fi
apt-get update -qq
apt-get install -y tor curl netcat-openbsd python3 python3-pip
pip3 install requests stem PySocks --quiet
HASHED=$(tor --hash-password "untraceable123" 2>/dev/null | tail -1)
sed -i '/^ControlPort/d;/^HashedControlPassword/d' /etc/tor/torrc
echo -e "\nControlPort 9051\nHashedControlPassword ${HASHED}" >> /etc/tor/torrc
systemctl restart tor
chmod +x untraceable-ip.sh scripts/*.sh
mkdir -p logs
echo "[+] Done! Run: sudo bash untraceable-ip.sh --start"
