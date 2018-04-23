#!/bin/bash

#wget --quiet https://github.com/beast-dev/beast-mcmc/releases/download/v1.8.4/BEASTv1.8.4.tgz
#tar -xzpf BEASTv1.8.4.tgz
#rm BEASTv1.8.4.tgz
#
#mv BEASTv1.8.4/bin/* /usr/local/bin
#mv BEASTv1.8.4/lib/* /usr/local/lib

cd /opt/docker

git clone https://github.com/beast-dev/beast-mcmc.git
cd beast-mcmc

ant dist

mv build/dist/* /usr/local/lib
mv release/Linux/lib/* /usr/local/lib
mv release/Linux/scripts/* /usr/local/bin

beast -beagle_info
