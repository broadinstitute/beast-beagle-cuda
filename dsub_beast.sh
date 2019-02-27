#!/bin/bash

# This is only a demonstration of how to run beast via dsub. 
# The accelerator (GPU) type and count should be set according to 
# the size of the data and number of partitions.

# --accelerator-count should scale with number of partitions in data
# --nvidia-driver-version must match compatible CUDA version
# 

function print_usage(){
    echo "Usage: $(basename $0) gs://path/to/in.xml gcp-project-name num_gpus [beagle_order]"
}

if [ $# -eq 0 ] || [ $# -lt 3 ]; then
    print_usage
    exit 1
fi

IN_XML="$1"
OUT_BUCKET="$(dirname $1)"
GCP_PROJECT="$2"
DOCKER_IMAGE="quay.io/broadinstitute/beast-beagle-cuda"
NUM_GPUS="$3"
GPU_TYPE="nvidia-tesla-k80" # see: https://cloud.google.com/compute/docs/gpus/
if [ -z "$4" ]; then
  BEAGLE_ORDER=1 # run on first GPU only
else
  BEAGLE_ORDER="$4"
fi

dsub \
  --provider=google-v2 \
  --project "${GCP_PROJECT}" \
  --zone "us*" \
  --accelerator-type "${GPU_TYPE}" \
  --nvidia-driver-version "396.37" \
  --accelerator-count "${NUM_GPUS}" \
  --image "${DOCKER_IMAGE}" \
  --input "INPUT_FILE=${IN_XML}" \
  --output "OUTPUT_FILES=${OUT_BUCKET}/*" \
  --logging "${OUT_BUCKET}" \
  --env BEAGLE_ORDER="${BEAGLE_ORDER}"\
  --script "run_beast.sh"  \
  --boot-disk-size 15 \
  #--wait
