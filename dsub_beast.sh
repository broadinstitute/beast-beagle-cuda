#!/bin/bash

# This is only a demonstration of how to run beast via dsub. 
# The accelerator (GPU) type and count should be set according to 
# the size of the data and number of partitions.

# --accelerator-count should scale with number of partitions in data
# --nvidia-driver-version must match compatible CUDA version
# 

function print_usage(){
  echo "Usage: "
  echo "  $(basename $0) gs://path/to/in.xml gcp-project-name num_gpus [beagle_order]"
  echo ""
  echo "  Note: The version of BEAST used should match the version of BEAUTi"
  echo "        used to generate the input xml file."
  echo ""
  echo "        Docker images have been built for several versions of BEAST."
  echo "        The Docker image to be used can be selected by environment variable. For example:"
  echo "          BEAST_VERSION='1.10.4' $(basename $0) gs://path/to/in.xml gcp-project-name num_gpus [beagle_order]"
  echo "        For available versions of BEAST, see the tags on Quay.io:"
  echo "          https://quay.io/repository/broadinstitute/beast-beagle-cuda?tab=tags"
  echo "        If BEAST_VERSION is not specified the 'latest' tag will be used."
}

if [ $# -eq 0 ] || [ $# -lt 3 ]; then
    print_usage
    exit 1
fi

function absolute_path() {
    local SOURCE="$1"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
        DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            SOURCE="$(readlink "$SOURCE")"
        else
            SOURCE="$(readlink -f "$SOURCE")"
        fi
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    echo "$SOURCE"
}
SOURCE="${BASH_SOURCE[0]}"
SCRIPT=$(absolute_path "$SOURCE")
SCRIPT_DIRNAME="$(dirname "$SOURCE")"
SCRIPTPATH="$(cd -P "$(echo $SCRIPT_DIRNAME)" &> /dev/null && pwd)"
SCRIPT="$SCRIPTPATH/$(basename "$SCRIPT")"

DOCKER_IMAGE="quay.io/broadinstitute/beast-beagle-cuda"
if [ -z "${BEAST_VERSION}" ]; then
  DOCKER_IMAGE_TAG=":latest"
else
  DOCKER_IMAGE_TAG=":${BEAST_VERSION}"
fi

IN_XML="$1"
OUT_BUCKET="$(dirname $1)"
GCP_PROJECT="$2"

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
  --image "${DOCKER_IMAGE}${DOCKER_IMAGE_TAG}" \
  --input "INPUT_FILE=${IN_XML}" \
  --output "OUTPUT_FILES=${OUT_BUCKET}/*" \
  --logging "${OUT_BUCKET}" \
  --env BEAGLE_ORDER="${BEAGLE_ORDER}"\
  --script "${SCRIPTPATH}/run_beast.sh"  \
  --boot-disk-size 15 \
  #--wait
