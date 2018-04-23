#!/bin/bash

set -e -o pipefail

# Silence some warnings about Readline. Checkout more over her$
# https://github.com/phusion/baseimage-docker/issues/58
DEBIAN_FRONTEND=noninteractive
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Add some basics
apt-get update
#--no-install-recommends
apt-get install -y -qq \
	lsb-release ca-certificates wget rsync curl \
	python-crcmod less nano vim git locales make \
	dirmngr \
	liblz4-tool pigz bzip2 lbzip2 zstd \
	libtool autoconf g++ \
	ant \
	openjdk-8-jre openjdk-8-jdk

# Add CUDA Toolkit
_DEB_NAME=cuda-repo-ubuntu1704_9.1.85-1_amd64.deb
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1704/x86_64/$_DEB_NAME
dpkg -i $_DEB_NAME
rm $_DEB_NAME
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1704/x86_64/7fa2af80.pub
apt-get update
apt-get install -y -qq --no-install-recommends cuda-9-1


# Auto-detect platform
DEBIAN_PLATFORM="$(lsb_release -c -s)"
#override for google cloud sdk
DEBIAN_PLATFORM="artful"
echo "Debian platform: $DEBIAN_PLATFORM"

# Add source for gcloud sdk
echo "deb http://packages.cloud.google.com/apt cloud-sdk-$DEBIAN_PLATFORM main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Install gcloud and aws
apt-get update
apt-get install -y -qq --no-install-recommends \
	google-cloud-sdk awscli

# Upgrade and clean
apt-get upgrade -y
apt-get clean

locale-gen en_US.UTF-8
