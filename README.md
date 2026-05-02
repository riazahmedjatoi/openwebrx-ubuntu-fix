# OpenWebRX — Ubuntu 24.04+ & Python 3.12+ Fix

![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04+-E95420?style=flat&logo=ubuntu)
![Python](https://img.shields.io/badge/Python-3.12+-3776AB?style=flat&logo=python)
![License](https://img.shields.io/badge/License-GPL3-green?style=flat)

OpenWebRX officially supports Ubuntu 22.04 (Jammy) only.  
This fix makes it work on **Ubuntu 24.04 (Noble) and above** with **Python 3.12+**.

---

## The Problem

```
python3-csdr → built against Python 3.10 only
libcsdr 0.18 → TimingRecovery symbol missing
librtlsdr0   → renamed to librtlsdr2 in Ubuntu 24.04
```

## The Fix

```
libcsdr 0.19  → built from source ✅
pycsdr        → compiled against Python 3.12+ ✅  
librtlsdr0    → compatibility package created ✅
owrx_connector → built from source ✅
```

---

## Tested On

| Ubuntu Version | Python Version | Status |
|---------------|----------------|--------|
| 22.04 Jammy   | 3.10           | ✅ Official |
| 24.04 Noble   | 3.12           | ✅ This Fix |
| 25.10 Oracular| 3.13           | 🔄 Testing |
| 26.04 Resolute| 3.14           | 🔄 Testing |

---

## One Command Install

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/riazahmedjatoi/openwebrx-ubuntu-fix/main/install.sh)"
```

### Or Manual

```bash
git clone https://github.com/riazahmedjatoi/openwebrx-ubuntu-fix.git
cd openwebrx-ubuntu-fix
sudo bash install.sh
```

---

## After Install

Open browser:
```
http://localhost:8073
```

First time admin setup:
```bash
sudo dpkg-reconfigure openwebrx
```

---

## What Gets Built

```
github.com/jketterl/csdr           → libcsdr 0.19
github.com/jketterl/pycsdr         → python3-csdr (Python 3.12+)
github.com/jketterl/owrx_connector → rtl_connector
```

---

## Why This Exists

The official OpenWebRX package repo ships pre-built `.deb` files  
compiled against Python 3.10. On newer Ubuntu versions with Python 3.12+,  
these packages fail with dependency errors and missing C++ symbols.

This fix rebuilds all C extensions natively against your installed  
Python version — making OpenWebRX work on any modern Ubuntu.

---

## Contributing

Found a bug or tested on a new version? Open an issue or PR!

---

## Credits

- [OpenWebRX](https://github.com/jketterl/openwebrx) by Jakob Ketterl
- Fix by [Riaz Ahmed Jatoi](https://github.com/riazahmedjatoi)