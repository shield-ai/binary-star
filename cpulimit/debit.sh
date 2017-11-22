#!/bin/bash

VERSION="1.0.0"
DEBFILE="cpulimit-shield_${VERSION}-stable_amd64.deb"

set -e

cd cpulimit

if [ -f ../../debs/"$DEBFILE" ]; then
  echo "Target version already exists. Aborting!"
  echo "FILE: $DEBFILE"
  exit 1
fi

cp ../description-pak .

# Clean up
make clean

# Build
make
sudo make install

# Checkinstalkl
sudo -k checkinstall \
  --install=no \
  --pkgsource="https://github.com/shield-ai/cpulimit" \
  --pkglicense="GPL-2.0" \
  --deldesc=no \
  --nodoc \
  --maintainer="$USER@shield.ai" \
  --pkgarch="$(dpkg --print-architecture)" \
  --pkgversion=$VERSION \
  --pkgrelease="stable" \
  --pkgname=cpulimit-shield \
  -y \
  make install

sudo chown "$USER":"$USER" $DEBFILE
mv $DEBFILE ../../debs
rm description-pak

set +e
