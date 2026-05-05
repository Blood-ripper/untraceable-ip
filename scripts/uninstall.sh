#!/bin/bash
sudo sed -i '/^ControlPort/d;/^HashedControlPassword/d' /etc/tor/torrc
sudo systemctl restart tor
echo "[+] Tor config restored."
