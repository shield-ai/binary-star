#!/bin/bash

VERSION="0.0.5"
TARGET_DIR="/opt/janus"

set -e

cd janus-gateway

if [ -f ../../debs/janus-gateway-shield_${VERSION}-stable_amd64.deb ]; then
  echo "Target version already exists. Aborting!"
  exit 1
fi

# Clean up
if [ -f Makefile ]; then
  make clean
fi

# Check pre-requisites
sudo apt install libmicrohttpd-dev libjansson-dev libnice-dev=0.1.13-0ubuntu3 \
  libssl-dev libsrtp-dev libsofia-sip-ua-dev libglib2.0-dev \
  libopus-dev libogg-dev libini-config-dev libcollection-dev \
  pkg-config gengetopt libtool automake dh-autoreconf libwebsockets-dev

# Configure janus-gateway
sh autogen.sh
./configure --disable-data-channels --disable-rabbitmq --disable-mqtt --prefix=$TARGET_DIR

# Build
make
sudo make install

# Move configs
sudo cp -r ./shieldconfigs/* "$TARGET_DIR/etc/janus/"

# Checkinstalkl
sudo -k checkinstall \
  --install=no \
  --pkgsource="https://github.com/shield-ai/janus-gateway" \
  --pkglicense="LGPL 2.1" \
  --deldesc=no \
  --nodoc \
  --maintainer="$USER@shield.ai" \
  --pkgarch="$(dpkg --print-architecture)" \
  --pkgversion=$VERSION \
  --pkgrelease="stable" \
  --pkgname=janus-gateway \
  --include=shieldconfigs \
  --requires="libmicrohttpd10,libjansson4,libnice10,libssl1.0.0,libsrtp0,libsofia-sip-ua0,libglib2.0-0,libopus0,libogg0,libini-config5,libcollection4,libwebsockets7" \
  -y \
  make install

dpkg -x janus-gateway_${VERSION}-stable_amd64.deb temp
cp -r shieldconfigs/* temp/opt/janus/etc/janus/
dpkg -e janus-gateway_${VERSION}-stable_amd64.deb temp/DEBIAN
dpkg -b temp ../../debs/janus-gateway-shield_${VERSION}-stable_amd64.deb

set +e
