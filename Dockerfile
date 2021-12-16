FROM nvidia/cuda:11.4.2-devel-ubuntu20.04

# CUDA version must be compatible with driver version of host:
#      via: https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html
# see also: https://cloud.google.com/container-optimized-os/docs/how-to/run-gpus#install
#           https://cloud.google.com/container-optimized-os/docs/release-notes
#
# CUDA Toolkit          Linux x86_64 Driver Version
#--------------------------------------------------
# CUDA 11.5             >= 495.29.05
# CUDA 11.4             >= 470.82.01
# CUDA 11.4             >= 470.57.02
# CUDA 11.4             >= 470.57.02
# CUDA 11.4.0           >= 470.42.01
# CUDA 11.3.1           >= 465.19.01
# CUDA 11.3.0           >= 465.19.01
# CUDA 11.2.2           >= 460.32.03
# CUDA 11.2.1           >= 460.32.03
# CUDA 11.2.0           >= 460.27.03
# CUDA 11.1.1           >= 455.32
# CUDA 11.1             >= 455.23
# CUDA 11.0.3           >= 450.51.06
# CUDA 11.0.2           >= 450.51.05
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
