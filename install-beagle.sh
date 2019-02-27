#!/bin/bash

set -e -o pipefail

cd /opt/docker

# beagle 3.1.2, known working with beast 1.10.4
git clone --depth=1 --branch="v3.1.2" https://github.com/beagle-dev/beagle-lib.git
cd beagle-lib

./autogen.sh
./configure --disable-sse --disable-march-native --prefix=/usr/local

make
make install
make check

ldconfig # LD_LIBRARY_PATH is also set in the Dockerfile to include /usr/local/lib