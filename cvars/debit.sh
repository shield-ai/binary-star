#!/bin/bash

BUILD_TYPE="RelWithDebInfo"
VERSION="7cbfe1f"
DEBFILE="cvars-shield_${VERSION}-${BUILD_TYPE}_amd64.deb"

set -e
set -o xtrace

cd CVars

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

# Check pre-requisites
sudo apt install -y libtinyxml-dev freeglut3-dev 

# Build
cmake -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" -DCMAKE_CXX_FLAGS='-march=native' ..
make -j4

# Checkinstalkl
sudo -k checkinstall \
  --install=no \
  --pkgsource="https://github.com/arpg/CVars.git" \
  --pkglicense="LGPL-3.0" \
  --deldesc=no \
  --nodoc \
  --maintainer="$USER@shield.ai" \
  --pkgarch="$(dpkg --print-architecture)" \
  --pkgversion=$VERSION \
  --pkgrelease="${BUILD_TYPE}" \
  --pkgname=cvars-shield \
  --requires="libtinyxml-dev,freeglut3-dev" \
  -y \
  make install

sudo chown "$USER":"$USER" $DEBFILE
dpkg -x $DEBFILE temp
ln -sf /usr/local/include/cvars temp/usr/local/include/CVars
dpkg -e $DEBFILE temp/DEBIAN
dpkg -b temp ../../../debs/$DEBFILE
rm -rf temp
rm description-pak
git reset --hard HEAD
git clean -fd .

set +e
set +o xtrace
