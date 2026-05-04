# OpenWebRX — Ubuntu 24.04+ & Python 3.12+ Fix

![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04+-E95420?style=flat&logo=ubuntu)
![Python](https://img.shields.io/badge/Python-3.12+-3776AB?style=flat&logo=python)
![License](https://img.shields.io/badge/License-GPL3-green?style=flat)
![Tested](https://img.shields.io/badge/Tested-Ubuntu%2026.04%20%2B%20Python%203.14-brightgreen?style=flat)

OpenWebRX officially supports Ubuntu 22.04 (Jammy) only.  
This fix makes it work on **Ubuntu 24.04 and above** with **Python 3.12, 3.13, and 3.14**.

---

## The Problem

```
python3-csdr  → built against Python 3.10 only
libcsdr 0.18  → TimingRecovery symbol missing in Python 3.12+
librtlsdr0    → renamed to librtlsdr2 in Ubuntu 24.04+
owrx_connector → links against wrong librtlsdr version
```

## The Fix

```
libcsdr 0.19   → built from source ✅
librtlsdr      → built from source (no version conflicts) ✅
pycsdr         → compiled against your Python version ✅
owrx_connector → built from source ✅
dummy packages → apt dependency resolution ✅
```

---

## Tested On

| Ubuntu Version        | Python Version | Status      |
|-----------------------|----------------|-------------|
| 22.04 LTS Jammy       | 3.10           | ✅ Official  |
| 24.04 LTS Noble       | 3.12           | ✅ This Fix  |
| 25.10 Questing        | 3.13           | ✅ This Fix  |
| 26.04 LTS Resolute    | 3.14.4         | ✅ This Fix  |

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

## What Gets Built From Source

```
github.com/jketterl/csdr           → libcsdr 0.19
github.com/osmocom/rtl-sdr         → librtlsdr (latest)
github.com/jketterl/pycsdr         → python3-csdr (any Python version)
github.com/jketterl/owrx_connector → rtl_connector + rtl_tcp_connector
```

---

## Why This Exists

The official OpenWebRX package repo ships pre-built `.deb` files compiled
against Python 3.10 on Ubuntu 22.04. On newer Ubuntu versions with Python
3.12+, these packages fail with:

- Dependency errors (`python3-csdr` requires `python3 < 3.11`)
- Missing C++ symbols (`TimingRecovery::canProcess`)
- Library renames (`librtlsdr0` → `librtlsdr2`)
- Version mismatches between Ubuntu releases

This script rebuilds all C extensions natively against your installed Python
and Ubuntu version — making OpenWebRX work on **any modern Ubuntu** without
Docker or virtual environments.

---

## How It Works

```
1. Build libcsdr 0.19 from source
2. Build librtlsdr from source (eliminates version conflicts)
3. Build pycsdr against your Python version
4. Build owrx_connector from source
5. Create apt compatibility dummy packages
6. Install OpenWebRX from official repo
```

---

## Contributing

Found a bug or tested on a new version? Open an issue or PR!

---

## Credits

- [OpenWebRX](https://github.com/jketterl/openwebrx) by Jakob Ketterl
- Fix by [Riaz Ahmed Jatoi](https://github.com/riazahmedjatoi)