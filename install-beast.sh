#!/bin/bash

beast_version="1.10.1"

wget --quiet https://github.com/beast-dev/beast-mcmc/releases/download/v1.10.4/BEASTv${beast_version}.tgz
tar -xzpf BEASTv${beast_version}.tgz
rm BEASTv${beast_version}.tgz

mv BEASTv${beast_version}/bin/* /usr/local/bin
mv BEASTv${beast_version}/lib/* /usr/local/lib

beast -beagle_info
