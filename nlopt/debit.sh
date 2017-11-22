#!/bin/bash

VERSION="9224141"
SRCFILE="nlopt-2.4.2"
DEBFILE="nlopt-shield_${VERSION}-stable_amd64.deb"

set -e

if [ -f ../../debs/"$DEBFILE" ]; then
  echo "Target version already exists. Aborting!"
  echo "FILE: $DEBFILE"
  exit 1
fi

wget https://github.com/ethz-asl/thirdparty_library_binaries/raw/master/"$SRCFILE".tar.gz
tar xzvf $SRCFILE.tar.gz
cd $SRCFILE

cp ../description-pak .

# Clean up
if [ -f Makefile ]; then
  make clean
fi

# Build
./configure --with-cxx --without-matlab --without-guile
make -j4

# Checkinstalkl
sudo -k checkinstall \
  --install=no \
  --pkgsource="https://github.com/edrosten/TooN" \
  --deldesc=no \
  --nodoc \
  --maintainer="$USER@shield.ai" \
  --pkgarch="$(dpkg --print-architecture)" \
  --pkgversion=$VERSION \
  --pkgrelease="stable" \
  --pkgname=nlopt-shield \
  -y \
  make install

sudo chown "$USER":"$USER" $DEBFILE
mv $DEBFILE ../../debs/

set +e
