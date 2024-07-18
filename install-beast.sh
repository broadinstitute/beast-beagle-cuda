#!/bin/bash

beast_version="BEAST_X_v10.5.0-beta3"

wget --quiet https://github.com/beast-dev/beast-mcmc/releases/download/v10.5.0-beta3/${beast_version}.tgz -O ${beast_version}.tgz

tar -xzpf ${beast_version}.tgz && mv BEAST*/ ${beast_version}
rm ${beast_version}.tgz

mv ${beast_version}/bin/* /usr/local/bin
mv ${beast_version}/lib/* /usr/local/lib

beast -beagle_info
