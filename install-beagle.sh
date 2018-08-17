#!/bin/bash

cd /opt/docker

git clone https://github.com/beagle-dev/beagle-lib.git
cd beagle-lib
## Nov 2017. Future commits break things?
#git checkout bcd2bf1a0b17703e8e24d56e0f1b5b4967470b8b

./autogen.sh
./configure --prefix=/usr/local

make

make check

make install
ldconfig

examples/genomictest/genomictest
examples/tinytest/tinytest
