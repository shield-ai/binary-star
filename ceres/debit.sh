#!/bin/bash

VERSION="1.11.0"
DEBFILE="ceres-solver-shield_${VERSION}-release_amd64.deb"

set -e

cd ceres-solver

if [ -f ../../debs/"$DEBFILE" ]; then
  echo "Target version already exists. Aborting!"
  echo "FILE: $DEBFILE"
  exit 1
fi

cp ../description-pak .

# Check pre-requisites
sudo apt install -y libeigen3-dev libgoogle-glog-dev

# Clean up
if [ -f build.ninja ]; then
  ninja clean
fi

# Build
cmake -DCMAKE_CXX_FLAGS=-fPIC -DGFLAGS=ON -DBUILD_SHARED_LIBS=ON -DBUILD_DOCUMENTATION=OFF -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_BUILD_TYPE:STRING=Release -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF -GNinja
ninja
sudo ninja install

# Checkinstalkl
sudo -k checkinstall \
  --install=no \
  --pkgsource="https://github.com/shield-ai/ceres-solver" \
  --deldesc=no \
  --nodoc \
  --maintainer="$USER@shield.ai" \
  --pkgarch="$(dpkg --print-architecture)" \
  --pkgversion=$VERSION \
  --pkgrelease="release" \
  --pkgname=ceres-solver-shield \
  --requires="libeigen3-dev,libgoogle-glog-dev" \
  -y \
  ninja install

sudo chown "$USER":"$USER" $DEBFILE
mv $DEBFILE ../../debs
rm description-pak
git reset --hard HEAD
git clean -fd .

set +e
