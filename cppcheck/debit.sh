#!/bin/bash

VERSION="1.80"
DEBFILE="cppcheck-shield_${VERSION}-stable_amd64.deb"

set -e
set -o xtrace

cd cppcheck

if [ -f ../../debs/"$DEBFILE" ]; then
  echo "Target version already exists. Aborting!"
  echo "FILE: $DEBFILE"
  exit 1
fi

mkdir -p build && cd build

cp ../../description-pak .

# Clean up
if [ -f build.ninja ]; then
  ninja clean
fi

# Build
cmake -GNinja ..
ninja

# Checkinstalkl
sudo -k checkinstall \
  --install=no \
  --pkgsource="https://github.com/danmar/cppcheck.git" \
  --pkglicense="GPL-3.0" \
  --deldesc=no \
  --nodoc \
  --maintainer="$USER@shield.ai" \
  --pkgarch="$(dpkg --print-architecture)" \
  --pkgversion=$VERSION \
  --pkgrelease="stable" \
  --pkgname=cppcheck-shield \
  -y \
  ninja install

sudo chown "$USER":"$USER" $DEBFILE
mv $DEBFILE ../../../debs/
rm description-pak

set +e
set +o xtrace
