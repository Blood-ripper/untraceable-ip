# 🧅 untraceable-ip — Tor IP Changer

> Automatically rotate your IP address through the Tor network on Kali Linux.  
> Built for **educational and personal privacy research** only.

---

## 📁 Project Structure

```
untraceable-ip/
├── untraceable-ip.sh          # Main script (entry point)
├── scripts/
│   ├── install.sh             # Auto-installer for Kali Linux
│   ├── uninstall.sh           # Cleanup / restore torrc
│   └── tor_controller.py      # Python-based Tor controller (stem)
├── config/
│   └── torrc.template         # Tor config reference
├── logs/                      # Auto-created at runtime
└── README.md
```

---

## ⚡ Quick Start (Kali Linux)

### 1. Clone the repo
```bash
git clone https://github.com/YOUR_USERNAME/untraceable-ip.git
cd untraceable-ip
```

### 2. Run the installer
```bash
sudo bash scripts/install.sh
```
This will:
- Install `tor`, `curl`, `netcat`, `python3`
- Install Python packages (`stem`, `requests`, `PySocks`)
- Configure `/etc/tor/torrc` with control port + hashed password
- Start the Tor service

### 3. Start rotating your IP
```bash
sudo bash untraceable-ip.sh --start
```

---

## 🛠️ Usage

```bash
sudo bash untraceable-ip.sh [option]
```

| Option | Description |
|---|---|
| `--start` | Start Tor & auto-rotate IP forever |
| `--ip` | Show current Tor IP only |
| `--once` | Rotate once then exit |
| `--interval <sec>` | Set rotation interval (default: 10s) |
| `--times <n>` | Rotate exactly N times then stop |
| `--stop` | Stop Tor service |
| `--install` | Run installer |
| `--help` | Show help |

### Examples

```bash
# Rotate every 30 seconds forever
sudo bash untraceable-ip.sh --interval 30

# Rotate exactly 5 times
sudo bash untraceable-ip.sh --times 5

# Just check what your Tor IP is right now
sudo bash untraceable-ip.sh --ip
```

---

## 🐍 Python Controller (Advanced)

```bash
# Show current IP
python3 scripts/tor_controller.py --ip

# Rotate 10 times, every 15 seconds
python3 scripts/tor_controller.py --times 10 --interval 15

# Infinite rotation
python3 scripts/tor_controller.py
```

---

## 🐳 Docker (Optional)

```bash
# Build
docker build -t untraceable-ip .

# Run (needs display for GUI version)
xhost +
docker run -p 14999:14999 -p 9050:9050 -e DISPLAY=$DISPLAY untraceable-ip
```

---

## 🔧 How It Works

1. **Tor** connects to the Tor network, routing traffic through 3 relays (entry → middle → exit)
2. The **SOCKS5 proxy** at `127.0.0.1:9050` lets any app route through Tor
3. Sending a **NEWNYM signal** to the control port (`9051`) requests a new Tor circuit
4. A new circuit = a new exit node = a new public IP address

```
You → Entry Node → Middle Node → Exit Node → Internet
                 (new circuit every N seconds)
```

---

## 📋 Requirements

- Kali Linux / any Debian-based distro
- `tor`, `curl`, `netcat-openbsd`
- Python 3 + `stem`, `requests`, `PySocks`
- Root / sudo access

---

## ⚠️ Disclaimer

This project is for **educational purposes and personal privacy research only**.  
Do not use this tool to conduct illegal activities.  
The author is not responsible for any misuse.

---

## 📄 License

GPL-3.0 — see [LICENSE](LICENSE)
