#!/bin/bash

set -e -o pipefail

nvcc --help

cd /opt/docker

# beagle 3.1.2, known working with beast 1.10.5pre
#git clone --depth=1 --branch="v3.1.2" https://github.com/beagle-dev/beagle-lib.git
# localize beagle pinned to commit aee7aae with changes since v3.1.2 release
git clone --depth=1 https://github.com/beagle-dev/beagle-lib.git
cd beagle-lib
git checkout aee7aae

mkdir build
cd build
cmake -DBUILD_OPENCL=OFF -DCMAKE_INSTALL_PREFIX:PATH=/usr/local ..
make install

pwd
echo "ls ."
ls -1 .

echo "ls ./examples"
ls -1 ./examples

echo "ls ./examples/synthetictest"
ls -1 ./examples/synthetictest

echo "ls ../"
ls -1 ../

echo "ls ../examples/synthetictest"
ls -1 ../examples/synthetictest

ldconfig # LD_LIBRARY_PATH is also set in the Dockerfile to include /usr/local/lib

examples/synthetictest

#examples/synthetictest/synthetictest
#examples/tinytest/tinytest