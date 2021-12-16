FROM nvidia/cuda:11.4.2-devel-ubuntu20.04

# CUDA version must be compatible with driver version of host:
# via https://docs.nvidia.com/deploy/cuda-compatibility/#minor-version-compatibility
#
# CUDA Toolkit          Linux x86_64 Driver Version
#--------------------------------------------------
# CUDA 11.x             >= 450.80.02
# CUDA 10.2             >= 440.33
# CUDA 10.1             >= 418.39
# CUDA 10.0 (10.0.130)  >= 410.48
# CUDA 9.2 (9.2.88)     >= 396.26
# CUDA 9.1 (9.1.85)     >= 390.46
# CUDA 9.0 (9.0.76)     >= 384.81
# CUDA 8.0 (8.0.61 GA2) >= 375.26
# CUDA 8.0 (8.0.44)     >= 367.48
# CUDA 7.5 (7.5.16)     >= 352.31
# CUDA 7.0 (7.0.28)     >= 346.46
#
# As of 2019-02-26, driver version 396.37 is suggested

LABEL maintainer "Daniel Park <dpark@broadinstitute.org>"
LABEL maintainer_other "Christopher Tomkins-Tinch <tomkinsc@broadinstitute.org>"

COPY install-*.sh /opt/docker/

# System packages, Google Cloud SDK, and locale
# ca-certificates and wget needed for gosu
# bzip2, liblz4-toolk, and pigz are useful for packaging and archival
# google-cloud-sdk needed when using this in GCE
RUN /opt/docker/install-apt_packages.sh

# Set default locale to en_US.UTF-8
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"
ENV LD_LIBRARY_PATH /usr/local/lib:${LD_LIBRARY_PATH}
ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs:${LIBRARY_PATH}

RUN /opt/docker/install-beagle.sh

RUN /opt/docker/install-beast.sh

ENV BEAST="/usr/local"

CMD ["/bin/bash"]
