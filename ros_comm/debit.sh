#!/bin/bash

set -e

sudo apt install python-bloom fakeroot dpkg-dev debhelper

# Get all directories that have code to build.
#PACKAGES=$(find . -name package.xml -exec bash -c 'test -f $(dirname "$1")/CMakeLists.txt' -- {} \; -print | grep -v test | xargs dirname)
PACKAGES="ros_comm/tools/rosbag ros_comm/tools/rosbag_storage"

for PACKAGE in $PACKAGES; do
  pushd "$PACKAGE" >> /dev/null
  echo "Building $PACKAGE"

  bloom-generate rosdebian --os-name ubuntu --os-version xenial --ros-distro kinetic
  fakeroot debian/rules binary

  popd >> /dev/null
done

find -name *.deb -exec mv {} ../debs \;

set +e
