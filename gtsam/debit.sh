#!/bin/bash

VERSION="8b0c2ecaf"
DEBFILE="gtsam-shield_${VERSION}-RelWithDebInfo_amd64.deb"

set -e
set -o xtrace

cd gtsam

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
CXX=clang++ CC=clang cmake -DGTSAM_USE_SYSTEM_EIGEN=ON -DGTSAM_WITH_EIGEN_MKL=OFF -GNinja -DGTSAM_BUILD_TESTS=OFF -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF -DCMAKE_BUILD_TYPE=RelWithDebInfo -DGTSAM_WITH_TBB=OFF ..
ninja

# Checkinstalkl
sudo -k checkinstall \
  --install=no \
  --pkgsource="https://bitbucket.org/gtborg/gtsam.git" \
  --pkglicense="GPL-2.0" \
  --deldesc=no \
  --nodoc \
  --maintainer="$USER@shield.ai" \
  --pkgarch="$(dpkg --print-architecture)" \
  --pkgversion=$VERSION \
  --pkgrelease="RelWithDebInfo" \
  --pkgname=gtsam-shield \
  -y \
  ninja install

sudo chown "$USER":"$USER" $DEBFILE
mv $DEBFILE ../../../debs/
rm description-pak

set +e
set +o xtrace
