#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}"
echo "================================================="
echo "  OpenWebRX Fix for Ubuntu 24.04+ / Python 3.12+"
echo "  By Riaz Ahmed Jatoi"
echo "  github.com/riazahmedjatoi/openwebrx-ubuntu-fix"
echo "================================================="
echo -e "${NC}"

# Root check
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: Please run as root${NC}"
  echo "Usage: sudo bash install.sh"
  exit 1
fi

# Ubuntu version check
UBUNTU_VERSION=$(lsb_release -rs)
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo -e "${YELLOW}Detected: Ubuntu $UBUNTU_VERSION | Python $PYTHON_VERSION${NC}"

# Step 1: Dependencies
echo -e "\n${GREEN}[1/7] Installing build dependencies...${NC}"
apt-get update -qq
apt-get install -y git cmake debhelper dh-python \
  python3-all python3-setuptools libusb-1.0-0-dev \
  librtlsdr-dev rtl-sdr equivs build-essential \
  libfftw3-dev lsb-release

# Step 2: OpenWebRX official repo
echo -e "\n${GREEN}[2/7] Adding OpenWebRX official repository...${NC}"
wget -q -O /usr/share/keyrings/openwebrx.gpg \
  https://repo.openwebrx.de/openwebrx.gpg
echo "deb [signed-by=/usr/share/keyrings/openwebrx.gpg] \
  https://repo.openwebrx.de/ubuntu/ jammy main" \
  > /etc/apt/sources.list.d/openwebrx.list
apt-get update -qq

# Step 3: libcsdr source se build
echo -e "\n${GREEN}[3/7] Building libcsdr 0.19 from source...${NC}"
cd /tmp
rm -rf csdr
git clone https://github.com/jketterl/csdr
cd csdr && mkdir -p build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
make install
ldconfig
cd /tmp

# Step 4: pycsdr build
echo -e "\n${GREEN}[4/7] Building pycsdr for Python $PYTHON_VERSION...${NC}"
cd /tmp
rm -rf pycsdr
git clone https://github.com/jketterl/pycsdr
cd pycsdr
dpkg-buildpackage -us -uc -b

# .so copy — key fix
PYTHON_TAG=$(python3 -c "import sys; print(f'cpython-{sys.version_info.major}{sys.version_info.minor}')")
NEW_SO=$(find .pybuild -name "modules.${PYTHON_TAG}-x86_64-linux-gnu.so" | head -1)

if [ -z "$NEW_SO" ]; then
  echo -e "${RED}Error: .so file not found!${NC}"
  exit 1
fi

# Pehle install karo phir .so replace karo
dpkg -i ../python3-csdr_*.deb
cp "$NEW_SO" /usr/lib/python3/dist-packages/pycsdr/modules.${PYTHON_TAG}-x86_64-linux-gnu.so
echo -e "${GREEN}.so file replaced successfully!${NC}"
cd /tmp

# Step 5: owrx_connector build
echo -e "\n${GREEN}[5/7] Building owrx_connector...${NC}"
cd /tmp
rm -rf owrx_connector
git clone https://github.com/jketterl/owrx_connector
cd owrx_connector && mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
make install
ldconfig
cd /tmp

# Step 6: librtlsdr0 dummy package
echo -e "\n${GREEN}[6/7] Creating librtlsdr0 compatibility package...${NC}"
mkdir -p /tmp/rtlsdr-dummy && cd /tmp/rtlsdr-dummy
cat > librtlsdr0-dummy << EOF
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: librtlsdr0
Version: 2.0.1
Description: Dummy package for librtlsdr0 → librtlsdr2 compatibility
EOF
equivs-build librtlsdr0-dummy
dpkg -i librtlsdr0_2.0.1_all.deb

# Step 7: OpenWebRX install
echo -e "\n${GREEN}[7/7] Installing OpenWebRX...${NC}"
apt-get install -y openwebrx

# Cleanup
echo -e "\n${YELLOW}Cleaning up...${NC}"
rm -rf /tmp/csdr /tmp/pycsdr /tmp/owrx_connector /tmp/rtlsdr-dummy

echo -e "\n${GREEN}"
echo "================================================="
echo "  OpenWebRX Successfully Installed!"
echo "  Open browser: http://localhost:8073"
echo "  Admin setup:  sudo dpkg-reconfigure openwebrx"
echo "================================================="
echo -e "${NC}"