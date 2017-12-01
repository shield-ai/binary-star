#!/bin/bash

VERSION="1.8.0"
DEBFILE="googletest-shield_${VERSION}-Release_amd64.deb"

set -e
set -o xtrace

cd googletest

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
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_GTEST=OFF -DBUILD_GMOCK=ON -GNinja ..
ninja

# Checkinstalkl
sudo -k checkinstall \
  --install=no \
  --pkgsource="https://github.com/google/googletest.git" \
  --pkglicense="BSD" \
  --deldesc=no \
  --nodoc \
  --maintainer="$USER@shield.ai" \
  --pkgarch="$(dpkg --print-architecture)" \
  --pkgversion=$VERSION \
  --pkgrelease="Release" \
  --pkgname=googletest-shield \
  -y \
  ninja install

sudo chown "$USER":"$USER" $DEBFILE
mv $DEBFILE ../../../debs/
rm description-pak

set +e
set +o xtrace
