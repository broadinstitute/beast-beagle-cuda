#!/bin/bash

## the section below pulls a named version

wget --quiet https://github.com/beast-dev/beast-mcmc/releases/download/v1.10.1/BEASTv1.10.1.tgz
tar -xzpf BEASTv1.10.1.tgz
rm BEASTv1.10.1.tgz

mv BEASTv1.10.1/bin/* /usr/local/bin
mv BEASTv1.10.1/lib/* /usr/local/lib

## the section below pulls the latest HEAD from master
#
#cd /opt/docker
#
#git clone https://github.com/beast-dev/beast-mcmc.git
#cd beast-mcmc
#
#ant dist
#
#mv build/dist/* /usr/local/lib
#mv release/Linux/lib/* /usr/local/lib
#mv release/Linux/scripts/* /usr/local/bin

## however it got installed, let's test that it works:
beast -beagle_info
