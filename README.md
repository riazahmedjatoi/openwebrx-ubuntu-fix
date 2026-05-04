# OpenWebRX — Ubuntu 24.04+ & Python 3.12+ Fix

![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04+-E95420?style=flat&logo=ubuntu)
![Python](https://img.shields.io/badge/Python-3.12+-3776AB?style=flat&logo=python)
![License](https://img.shields.io/badge/License-GPL3-green?style=flat)
![Tested](https://img.shields.io/badge/Tested-Ubuntu%2026.04%20%2B%20Python%203.14-brightgreen?style=flat)

> One command to install OpenWebRX on any modern Ubuntu — no Docker, no virtual environments, no manual steps.

---

## The Problem

OpenWebRX officially supports only **Ubuntu 22.04 (Jammy) + Python 3.10**.

On newer Ubuntu versions, installation fails with these errors:

```
python3-csdr : Depends: python3 (< 3.11) but 3.12 is installed
librtlsdr0 : Depends: librtlsdr0 (>= 0.6.0) but it is not installable
ImportError: undefined symbol: _ZN4Csdr14TimingRecoveryIfE10canProcessEv
```

**Root causes:**
- `python3-csdr` was pre-built against Python 3.10 only
- `libcsdr 0.18` is missing the `TimingRecovery` symbol required by newer builds
- `librtlsdr0` was renamed to `librtlsdr2` in Ubuntu 24.04+
- Every Ubuntu version ships a different `librtlsdr` build number causing exact version conflicts

---

## The Fix

This script rebuilds all C extensions from source — natively against your installed Python and Ubuntu version.

```
libcsdr 0.19        → built from source (all symbols present)
librtlsdr           → built from source (no version conflicts)
pycsdr              → compiled against your Python version
owrx_connector      → built from source
apt dummy packages  → satisfy dependency resolver
```

---

## Tested On

| Ubuntu Version         | Codename  | Python  | Status       |
|------------------------|-----------|---------|--------------|
| 22.04 LTS              | Jammy     | 3.10    | ✅ Official   |
| 24.04 LTS              | Noble     | 3.12.3  | ✅ This Fix   |
| 25.10                  | Questing  | 3.13.7  | ✅ This Fix   |
| 26.04 LTS              | Resolute  | 3.14.4  | ✅ This Fix   |

---

## Requirements

- Ubuntu 24.04 or newer
- Internet connection
- Root / sudo access
- ~1.5 GB free disk space
- ~10-15 minutes (build time depends on CPU)

---

## Installation

### One Command (Recommended)

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/riazahmedjatoi/openwebrx-ubuntu-fix/main/install.sh)"
```

### Manual

```bash
git clone https://github.com/riazahmedjatoi/openwebrx-ubuntu-fix.git
cd openwebrx-ubuntu-fix
sudo bash install.sh
```

---

## After Installation

**1. Open browser:**
```
http://localhost:8073
```

**2. First time admin setup:**
```bash
sudo dpkg-reconfigure openwebrx
```

**3. Service management:**
```bash
# Start
sudo systemctl start openwebrx

# Stop
sudo systemctl stop openwebrx

# Restart
sudo systemctl restart openwebrx

# Status
sudo systemctl status openwebrx

# Auto start on boot
sudo systemctl enable openwebrx
```

**4. Check logs:**
```bash
sudo journalctl -u openwebrx -f
```

---

## What Gets Built

| Component | Source | Purpose |
|-----------|--------|---------|
| `libcsdr 0.19` | [jketterl/csdr](https://github.com/jketterl/csdr) | DSP library |
| `librtlsdr` | [osmocom/rtl-sdr](https://github.com/osmocom/rtl-sdr) | RTL-SDR hardware support |
| `python3-csdr` | [jketterl/pycsdr](https://github.com/jketterl/pycsdr) | Python bindings |
| `owrx_connector` | [jketterl/owrx_connector](https://github.com/jketterl/owrx_connector) | SDR connector |
| `openwebrx` | [Official repo](https://repo.openwebrx.de) | Main application |

---

## SDR Hardware Setup

After installation, connect your RTL-SDR dongle and configure it in OpenWebRX settings at `http://localhost:8073`.

**Verify hardware detection:**
```bash
rtl_test -t
```

**Supported devices:**
- RTL-SDR (RTL2832U based)
- AirSpy
- SDRplay
- HackRF
- PlutoSDR
- And more via SoapySDR

---

## Troubleshooting

**Service not starting:**
```bash
sudo journalctl -u openwebrx -n 50 --no-pager
```

**No SDR device found:**
```bash
# Check USB device
lsusb | grep RTL
rtl_test -t
```

**Port 8073 not accessible:**
```bash
sudo ss -tlnp | grep 8073
sudo systemctl restart openwebrx
```

**Reinstall from scratch:**
```bash
sudo apt-get remove -y openwebrx python3-csdr
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/riazahmedjatoi/openwebrx-ubuntu-fix/main/install.sh)"
```

---

## How It Works (Technical)

```
Step 1  Install build tools + dependencies
Step 2  Add OpenWebRX official apt repository
Step 3  Build libcsdr 0.19 from source → /usr/lib
Step 4  Build librtlsdr from source → /usr/lib
Step 5  Create apt dummy packages (satisfy dependency resolver)
Step 6  Build pycsdr against your Python version
        Copy .so file to correct location
Step 7  Build owrx_connector from source
Step 8  Verify library linkage
Step 9  Install OpenWebRX from official repo
        Cleanup temporary files
```

---

## Contributing

Tested on a new Ubuntu version? Found a bug? PRs and issues are welcome!

1. Fork this repo
2. Test on your system
3. Open a PR with your findings

---

## Credits

- [OpenWebRX](https://github.com/jketterl/openwebrx) by Jakob Ketterl (DD5JFK)
- [libcsdr](https://github.com/jketterl/csdr) by Jakob Ketterl
- [pycsdr](https://github.com/jketterl/pycsdr) by Jakob Ketterl
- [owrx_connector](https://github.com/jketterl/owrx_connector) by Jakob Ketterl
- [rtl-sdr](https://github.com/osmocom/rtl-sdr) by Osmocom
- Fix & compatibility script by [Riaz Ahmed Jatoi](https://github.com/riazahmedjatoi)

---

## License

GPL-3.0 — same as OpenWebRX