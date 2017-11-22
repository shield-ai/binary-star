#!/bin/bash

VERSION="9224141"
DEBFILE="toon-shield_${VERSION}-stable_amd64.deb"

set -e

cd TooN

if [ -f ../../debs/"$DEBFILE" ]; then
  echo "Target version already exists. Aborting!"
  echo "FILE: $DEBFILE"
  exit 1
fi

cp ../description-pak .

# Clean up
if [ -f Makefile ]; then
  make clean
fi

# Build
./configure
make

# Checkinstalkl
sudo -k checkinstall \
  --install=no \
  --pkgsource="https://github.com/edrosten/TooN" \
  --pkglicense="BSD-2-Clause" \
  --deldesc=no \
  --nodoc \
  --maintainer="$USER@shield.ai" \
  --pkgarch="$(dpkg --print-architecture)" \
  --pkgversion=$VERSION \
  --pkgrelease="stable" \
  --pkgname=toon-shield \
  -y \
  make install

sudo chown "$USER":"$USER" $DEBFILE
mv $DEBFILE ../../debs
rm description-pak
git reset --hard HEAD
git clean -fd .

set +e
