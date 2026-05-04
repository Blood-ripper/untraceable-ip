#!/bin/bash
# ============================================================
#  untraceable-ip.sh — Tor IP Changer
#  Author  : Your Name
#  License : GPL-3.0
#  Platform: Kali Linux / Debian-based
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

TOR_SOCKS="socks5h://127.0.0.1:9050"
CONTROL_PORT=9051
CONTROL_PASS="untraceable123"   # change after install
LOG_FILE="./logs/ip-changer.log"
INTERVAL=10                     # seconds between rotations
ROTATIONS=0                     # 0 = run until Ctrl+C

banner() {
  clear
  echo -e "${CYAN}${BOLD}"
  echo "  ██╗   ██╗███╗   ██╗████████╗██████╗  █████╗  ██████╗███████╗"
  echo "  ██║   ██║████╗  ██║╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██╔════╝"
  echo "  ██║   ██║██╔██╗ ██║   ██║   ██████╔╝███████║██║     █████╗  "
  echo "  ██║   ██║██║╚██╗██║   ██║   ██╔══██╗██╔══██║██║     ██╔══╝  "
  echo "  ╚██████╔╝██║ ╚████║   ██║   ██║  ██║██║  ██║╚██████╗███████╗"
  echo "   ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝"
  echo -e "${NC}"
  echo -e "${YELLOW}         Tor IP Changer | Kali Linux Edition${NC}"
  echo -e "${RED}  For educational / personal privacy use only${NC}"
  echo "  ============================================================"
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

check_deps() {
  echo -e "\n${CYAN}[*] Checking dependencies...${NC}"
  local missing=()
  for cmd in tor curl python3; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("$cmd")
    fi
  done
  if [ ${#missing[@]} -ne 0 ]; then
    echo -e "${RED}[-] Missing: ${missing[*]}${NC}"
    echo -e "${YELLOW}[!] Run: ./scripts/install.sh${NC}"
    exit 1
  fi
  echo -e "${GREEN}[+] All dependencies found.${NC}"
}

start_tor() {
  echo -e "${CYAN}[*] Starting Tor service...${NC}"
  sudo systemctl start tor 2>/dev/null || sudo service tor start 2>/dev/null
  sleep 3
  if systemctl is-active --quiet tor 2>/dev/null || pgrep -x tor &>/dev/null; then
    echo -e "${GREEN}[+] Tor is running.${NC}"
    log "Tor service started."
  else
    echo -e "${RED}[-] Failed to start Tor. Check torrc config.${NC}"
    exit 1
  fi
}

stop_tor() {
  echo -e "\n${YELLOW}[!] Stopping Tor...${NC}"
  sudo systemctl stop tor 2>/dev/null || sudo service tor stop 2>/dev/null
  log "Tor service stopped."
}

get_ip() {
  curl -s --proxy "$TOR_SOCKS" --max-time 10 https://api.ipify.org 2>/dev/null
}

renew_identity() {
  echo -e "AUTHENTICATE \"${CONTROL_PASS}\"\r\nSIGNAL NEWNYM\r\nQUIT" \
    | nc -w 3 127.0.0.1 "$CONTROL_PORT" &>/dev/null
}

rotate_once() {
  local old_ip
  old_ip=$(get_ip)
  echo -e "${CYAN}[*] Current IP : ${BOLD}${old_ip}${NC}"
  log "Current IP: $old_ip"

  renew_identity
  sleep "$INTERVAL"

  local new_ip
  new_ip=$(get_ip)
  if [[ "$old_ip" != "$new_ip" && -n "$new_ip" ]]; then
    echo -e "${GREEN}[+] New IP     : ${BOLD}${new_ip}${NC}"
    log "New IP: $new_ip"
  else
    echo -e "${YELLOW}[~] IP unchanged (circuit reuse — retrying next round)${NC}"
    log "IP unchanged: $new_ip"
  fi
  echo "  ------------------------------------------------------------"
}

run_auto() {
  local count=0
  echo -e "\n${GREEN}[+] Auto-rotate mode | Interval: ${INTERVAL}s | Press Ctrl+C to stop${NC}\n"
  trap 'echo -e "\n${YELLOW}[!] Interrupted.${NC}"; stop_tor; exit 0' INT
  while true; do
    count=$((count + 1))
    echo -e "${BOLD}--- Rotation #${count} ---${NC}"
    rotate_once
    if [[ "$ROTATIONS" -gt 0 && "$count" -ge "$ROTATIONS" ]]; then
      echo -e "${GREEN}[+] Done. Completed ${count} rotations.${NC}"
      break
    fi
  done
}

show_current_ip() {
  start_tor
  local ip
  ip=$(get_ip)
  echo -e "\n${GREEN}[+] Your Tor IP: ${BOLD}${ip}${NC}\n"
}

usage() {
  echo -e "\n${BOLD}Usage:${NC} $0 [option]\n"
  echo "  --start          Start Tor & begin auto IP rotation"
  echo "  --ip             Show current Tor IP only"
  echo "  --once           Rotate IP one time then exit"
  echo "  --interval <sec> Set rotation interval (default: 10s)"
  echo "  --times <n>      Rotate exactly N times then stop"
  echo "  --stop           Stop Tor service"
  echo "  --install        Run installer (same as scripts/install.sh)"
  echo "  --help           Show this help"
  echo ""
}

# ── Entry Point ─────────────────────────────────────────────
mkdir -p logs
banner
check_deps

case "$1" in
  --start)
    start_tor
    run_auto
    ;;
  --ip)
    show_current_ip
    ;;
  --once)
    start_tor
    echo -e "\n${CYAN}[*] Single rotation...${NC}\n"
    rotate_once
    ;;
  --interval)
    INTERVAL="${2:-10}"
    start_tor
    run_auto
    ;;
  --times)
    ROTATIONS="${2:-5}"
    start_tor
    run_auto
    ;;
  --stop)
    stop_tor
    ;;
  --install)
    bash ./scripts/install.sh
    ;;
  --help|*)
    usage
    ;;
esac
