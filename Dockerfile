FROM ubuntu:bionic-20180410

LABEL maintainer "Daniel Park <dpark@broadinstitute.org>"

COPY install-*.sh /opt/docker/

# System packages, Google Cloud SDK, and locale
# ca-certificates and wget needed for gosu
# bzip2, liblz4-toolk, and pigz are useful for packaging and archival
# google-cloud-sdk needed when using this in GCE
RUN /opt/docker/install-apt_packages.sh

# Set default locale to en_US.UTF-8
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"

RUN /opt/docker/install-beagle.sh

RUN /opt/docker/install-beast.sh

ENTRYPOINT ["/bin/bash"]
