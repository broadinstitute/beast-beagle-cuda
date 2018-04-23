#!/bin/bash

cd /opt/docker

git clone https://github.com/beagle-dev/beagle-lib.git
cd beagle-lib

./autogen.sh
./configure --prefix=/usr/local

make

make check

make install
ldconfig

examples/genomictest/genomictest
examples/tinytest/tinytest
