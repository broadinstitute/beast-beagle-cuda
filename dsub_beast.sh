#!/bin/bash

# This is only a demonstration of how to run beast via dsub. 
# The accelerator (GPU) type and count should be set according to 
# the size of the data and number of partitions.

# --accelerator-count should scale with number of partitions in data
# --nvidia-driver-version must match compatible CUDA version
# 

function print_usage(){
    echo "Usage: $(basename $SCRIPT) gs://path/to/in.xml gcp-project-name"
}

if [ $# -eq 0 ]; then
    print_usage
    exit 1
fi

IN_XML="$1"
OUT_BUCKET="$(dirname $1)"
GCP_PROJECT="$2"
DOCKER_IMAGE="quay.io/broadinstitute/beast-beagle-cuda"

dsub \
  --provider=google-v2 \
  --project "${GCP_PROJECT}" \
  --zone "us*" \
  --accelerator-type "nvidia-tesla-k80" \
  --nvidia-driver-version "396.37" \
  --accelerator-count 1 \
  --image "${DOCKER_IMAGE}" \
  --input "INPUT_FILE=${IN_XML}" \
  --output "OUTPUT_FILES=${OUT_BUCKET}/*" \
  --logging "${OUT_BUCKET}" \
  --script 'run_beast.sh' \
  --boot-disk-size 30 \
  --wait
