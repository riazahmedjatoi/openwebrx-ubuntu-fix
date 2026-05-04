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

# lsb-release aur python3 pehle install karo
apt-get update -qq
apt-get install -y lsb-release python3 -qq

# Version detect
UBUNTU_VERSION=$(lsb_release -rs)
UBUNTU_CODENAME=$(lsb_release -cs)
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
PYTHON_TAG=$(python3 -c "import sys; print(f'cpython-{sys.version_info.major}{sys.version_info.minor}')")

echo -e "${YELLOW}Detected: Ubuntu $UBUNTU_VERSION ($UBUNTU_CODENAME) | Python $PYTHON_VERSION${NC}"

# Step 1: Build Dependencies
echo -e "\n${GREEN}[1/9] Installing build dependencies...${NC}"
apt-get install -y \
  git cmake build-essential pkg-config \
  debhelper dh-python equivs \
  python3-all python3-setuptools python3-dev libpython3-dev \
  libusb-1.0-0-dev libfftw3-dev libsamplerate0-dev \
  wget curl -qq

# Step 2: OpenWebRX official repo
echo -e "\n${GREEN}[2/9] Adding OpenWebRX official repository...${NC}"
wget -q -O /usr/share/keyrings/openwebrx.gpg \
  https://repo.openwebrx.de/openwebrx.gpg
echo "deb [signed-by=/usr/share/keyrings/openwebrx.gpg] \
  https://repo.openwebrx.de/ubuntu/ jammy main" \
  > /etc/apt/sources.list.d/openwebrx.list
apt-get update -qq

# Step 3: libcsdr source se build
echo -e "\n${GREEN}[3/9] Building libcsdr 0.19 from source...${NC}"
cd /tmp && rm -rf csdr
git clone https://github.com/jketterl/csdr
cd csdr && mkdir -p build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
make install
ldconfig
cd /tmp

# Step 4: librtlsdr source se build — apt wala nahi
echo -e "\n${GREEN}[4/9] Building librtlsdr from source...${NC}"
cd /tmp && rm -rf rtl-sdr
git clone https://github.com/osmocom/rtl-sdr
cd rtl-sdr && mkdir -p build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
make install
ldconfig
cd /tmp

# Step 5: Dummy packages banao
echo -e "\n${GREEN}[5/9] Creating compatibility dummy packages...${NC}"
mkdir -p /tmp/dummies && cd /tmp/dummies

# libcsdr0 dummy
cat > libcsdr0-dummy << EOF
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: libcsdr0
Version: 0.19.0
Description: Dummy package for libcsdr0
EOF
equivs-build libcsdr0-dummy
dpkg -i libcsdr0_0.19.0_all.deb

# libcsdr-dev dummy
cat > libcsdr-dev-dummy << EOF
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: libcsdr-dev
Version: 0.19.0
Provides: libcsdr-dev
Description: Dummy package for libcsdr-dev
EOF
equivs-build libcsdr-dev-dummy
dpkg -i libcsdr-dev_0.19.0_all.deb

# librtlsdr0 dummy — exact version detect karo jo librtlsdr-dev expect karta hai
RTLSDR_DEP_VER=$(apt-cache show librtlsdr-dev 2>/dev/null \
  | grep "^Depends:" \
  | grep -o 'librtlsdr0 (= [^)]*' \
  | sed 's/librtlsdr0 (= //' \
  | head -1)
if [ -z "$RTLSDR_DEP_VER" ]; then
  RTLSDR_DEP_VER="2.0.2-2"
fi
echo "librtlsdr0 dummy version: $RTLSDR_DEP_VER"

cat > librtlsdr0-dummy << EOF
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: librtlsdr0
Version: $RTLSDR_DEP_VER
Description: Dummy package for librtlsdr0 compatibility
EOF
equivs-build librtlsdr0-dummy
dpkg -i librtlsdr0_${RTLSDR_DEP_VER}_all.deb

# librtlsdr2 dummy
cat > librtlsdr2-dummy << EOF
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: librtlsdr2
Version: $RTLSDR_DEP_VER
Description: Dummy package for librtlsdr2 compatibility
EOF
equivs-build librtlsdr2-dummy
dpkg -i librtlsdr2_${RTLSDR_DEP_VER}_all.deb

# rtl-sdr dummy
cat > rtl-sdr-dummy << EOF
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: rtl-sdr
Version: $RTLSDR_DEP_VER
Description: Dummy package for rtl-sdr
EOF
equivs-build rtl-sdr-dummy
dpkg -i rtl-sdr_${RTLSDR_DEP_VER}_all.deb

# librtlsdr-dev dummy
cat > librtlsdr-dev-dummy << EOF
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: librtlsdr-dev
Version: $RTLSDR_DEP_VER
Provides: librtlsdr-dev
Description: Dummy package for librtlsdr-dev
EOF
equivs-build librtlsdr-dev-dummy
dpkg -i librtlsdr-dev_${RTLSDR_DEP_VER}_all.deb

# soapysdr-tools dummy
cat > soapysdr-tools-dummy << EOF
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: soapysdr-tools
Version: 0.8.0
Description: Dummy package for soapysdr-tools
EOF
equivs-build soapysdr-tools-dummy
dpkg -i soapysdr-tools_0.8.0_all.deb

cd /tmp

# Step 6: pycsdr build
echo -e "\n${GREEN}[6/9] Building pycsdr for Python $PYTHON_VERSION...${NC}"
cd /tmp && rm -rf pycsdr
git clone https://github.com/jketterl/pycsdr
cd pycsdr

# debian/rules fix — TAB required
python3 -c "
content = '#!/usr/bin/make -f\nexport PYBUILD_NAME=pycsdr\n%:\n\tdh \$@ --with python3 --buildsystem=pybuild\n\noverride_dh_shlibdeps:\n\tdh_shlibdeps --dpkg-shlibdeps-params=--ignore-missing-info\n'
open('debian/rules', 'w').write(content)
"

dpkg-buildpackage -us -uc -b -d

# .so copy — key fix
NEW_SO=$(find .pybuild -name "modules.${PYTHON_TAG}-x86_64-linux-gnu.so" | head -1)
if [ -z "$NEW_SO" ]; then
  echo -e "${RED}Error: .so file not found for $PYTHON_TAG!${NC}"
  exit 1
fi

dpkg -i ../python3-csdr_*.deb
cp "$NEW_SO" /usr/lib/python3/dist-packages/pycsdr/modules.${PYTHON_TAG}-x86_64-linux-gnu.so
echo -e "${GREEN}.so replaced: $PYTHON_TAG${NC}"
cd /tmp

# Step 7: owrx_connector build
echo -e "\n${GREEN}[7/9] Building owrx_connector...${NC}"
cd /tmp && rm -rf owrx_connector

# Static library hata do — shared use hogi
rm -f /usr/lib/x86_64-linux-gnu/librtlsdr.a

git clone https://github.com/jketterl/owrx_connector
cd owrx_connector && mkdir -p build && cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5
make -j$(nproc)
make install
ldconfig
cd /tmp

# owrx-connector dummy
cd /tmp/dummies
cat > owrx-connector-dummy << EOF
Section: misc
Priority: optional
Standards-Version: 3.9.2
Package: owrx-connector
Version: 0.7.0
Description: Dummy package for owrx-connector
EOF
equivs-build owrx-connector-dummy
dpkg -i owrx-connector_0.7.0_all.deb
cd /tmp

# Step 8: Verify
echo -e "\n${GREEN}[8/9] Verifying...${NC}"
SO_FILE="/usr/lib/python3/dist-packages/pycsdr/modules.${PYTHON_TAG}-x86_64-linux-gnu.so"
if ldd "$SO_FILE" | grep -q "libcsdr"; then
  echo -e "${GREEN}libcsdr linked correctly!${NC}"
else
  echo -e "${RED}Warning: libcsdr not linked!${NC}"
fi

# Step 9: OpenWebRX install
echo -e "\n${GREEN}[9/9] Installing OpenWebRX...${NC}"
apt-get install -y --no-install-recommends openwebrx

# Cleanup
rm -rf /tmp/csdr /tmp/rtl-sdr /tmp/pycsdr /tmp/owrx_connector /tmp/dummies

echo -e "\n${GREEN}"
echo "================================================="
echo "  OpenWebRX Successfully Installed!"
echo "  Ubuntu: $UBUNTU_VERSION | Python: $PYTHON_VERSION"
echo "  Open browser: http://localhost:8073"
echo "  Admin setup:  sudo dpkg-reconfigure openwebrx"
echo "================================================="
echo -e "${NC}"