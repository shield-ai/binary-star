#!/bin/bash

BUILD_TYPE="Release"
VERSION="3.2.8"
DEBFILE="eigen3-shield_${VERSION}-${BUILD_TYPE}_amd64.deb"

set -e
set -o xtrace

cd eigen

if [ -f ../../debs/"$DEBFILE" ]; then
  echo "Target version already exists. Aborting!"
  echo "FILE: $DEBFILE"
  exit 1
fi

mkdir -p build && cd build

cp ../../description-pak .

# Clean up
if [ -f Makefile ]; then
  make clean
fi

# Build
cmake -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" ..
make -j4

# Checkinstalkl
sudo -k checkinstall \
  --install=no \
  --pkgsource="https://github.com/RLovelett/eigen.git" \
  --pkglicense="BSD-3-Clause" \
  --deldesc=no \
  --nodoc \
  --maintainer="$USER@shield.ai" \
  --pkgarch="$(dpkg --print-architecture)" \
  --pkgversion=$VERSION \
  --pkgrelease="${BUILD_TYPE}" \
  --pkgname=eigen3-shield \
  -y \
  make install

sudo chown "$USER":"$USER" $DEBFILE
mv $DEBFILE ../../../debs/
rm description-pak
cd ../
rm -rf build

set +e
set +o xtrace
