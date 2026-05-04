#!/bin/bash
# ============================================================
#  install.sh — Setup script for untraceable-ip on Kali Linux
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

CONTROL_PASS="untraceable123"   # must match untraceable-ip.sh

echo -e "${CYAN}"
echo "  [+] untraceable-ip — Installer"
echo "  Platform: Kali Linux / Debian"
echo -e "${NC}"

# ── 1. Root check ────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}[-] Please run as root: sudo bash scripts/install.sh${NC}"
  exit 1
fi

# ── 2. Update & install packages ─────────────────────────────
echo -e "${CYAN}[*] Updating package list...${NC}"
apt-get update -qq

echo -e "${CYAN}[*] Installing tor, curl, netcat, python3...${NC}"
apt-get install -y tor curl netcat-openbsd python3 python3-pip &>/dev/null
echo -e "${GREEN}[+] Packages installed.${NC}"

# ── 3. Install Python deps (stem for advanced use) ───────────
echo -e "${CYAN}[*] Installing Python packages...${NC}"
pip3 install requests stem PySocks --quiet
echo -e "${GREEN}[+] Python packages ready.${NC}"

# ── 4. Configure torrc ───────────────────────────────────────
TORRC="/etc/tor/torrc"
TORRC_BACKUP="/etc/tor/torrc.bak"

echo -e "${CYAN}[*] Configuring Tor control port...${NC}"
cp "$TORRC" "$TORRC_BACKUP" 2>/dev/null

HASHED_PASS=$(tor --hash-password "$CONTROL_PASS" 2>/dev/null | tail -1)

# Remove old control lines if present
sed -i '/^ControlPort/d' "$TORRC"
sed -i '/^HashedControlPassword/d' "$TORRC"

# Append new config
cat >> "$TORRC" <<EOF

# --- untraceable-ip config ---
ControlPort 9051
HashedControlPassword ${HASHED_PASS}
EOF

echo -e "${GREEN}[+] torrc updated (backup: ${TORRC_BACKUP})${NC}"

# ── 5. Restart Tor ───────────────────────────────────────────
echo -e "${CYAN}[*] Restarting Tor...${NC}"
systemctl restart tor
sleep 3
if systemctl is-active --quiet tor; then
  echo -e "${GREEN}[+] Tor service running.${NC}"
else
  echo -e "${RED}[-] Tor failed to start. Check: journalctl -xe | grep tor${NC}"
  exit 1
fi

# ── 6. Make main script executable ───────────────────────────
chmod +x "$(dirname "$0")/../untraceable-ip.sh"
chmod +x "$(dirname "$0")"/*.sh

# ── 7. Create logs dir ───────────────────────────────────────
mkdir -p "$(dirname "$0")/../logs"

# ── 8. Done ──────────────────────────────────────────────────
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Installation complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "  Run: ${YELLOW}sudo bash untraceable-ip.sh --start${NC}"
echo -e "  IP : ${YELLOW}sudo bash untraceable-ip.sh --ip${NC}"
echo -e "  Help: ${YELLOW}sudo bash untraceable-ip.sh --help${NC}"
echo ""
