#!/bin/bash

#### normal stuff here
#beast_version="1.10.5pre_thorney_0.1.2"
## uncomment when out of pre-release:
##wget --quiet https://github.com/beast-dev/beast-mcmc/releases/download/v${beast_version}/BEASTv${beast_version}.tgz
#wget --quiet https://github.com/beast-dev/beast-mcmc/releases/download/v1.10.5pre_thorney_v0.1.2/BEASTv1.10.5pre_thorney_0.1.2.tgz -O BEASTv${beast_version}.tgz
#
#tar -xzpf BEASTv${beast_version}.tgz
#rm BEASTv${beast_version}.tgz
#
#mv BEASTv${beast_version}/bin/* /usr/local/bin
#mv BEASTv${beast_version}/lib/* /usr/local/lib


#### pull dev hotfix version from Marc
git clone --depth=1 --branch hmc-clock https://github.com/beast-dev/beast-mcmc.git
cd beast-mcmc
ant dist
mv bin/* /usr/local/bin
mv lib/* /usr/local/lib

#### test
beast -beagle_info
