#!/bin/bash

beast_version="v10.5.0-beta3"
beast_name="BEAST_X_${beast_version}"

wget --quiet https://github.com/beast-dev/beast-mcmc/releases/download/${beast_version}/${beast_name}.tgz -O ${beast_name}.tgz

tar -xzpf ${beast_name}.tgz && mv BEAST*/ ${beast_name}
rm ${beast_name}.tgz

mv ${beast_name}/bin/* /usr/local/bin
mv ${beast_name}/lib/* /usr/local/lib

beast -beagle_info
