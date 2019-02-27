#!/bin/bash

wget --quiet https://github.com/beast-dev/beast-mcmc/releases/download/v1.10.4/BEASTv1.10.4.tgz
tar -xzpf BEASTv1.10.4.tgz
rm BEASTv1.10.4.tgz

mv BEASTv1.10.4/bin/* /usr/local/bin
mv BEASTv1.10.4/lib/* /usr/local/lib

beast -beagle_info
