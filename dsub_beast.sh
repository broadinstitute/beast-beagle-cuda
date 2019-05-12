#!/bin/bash

# This is only a demonstration of how to run beast via dsub. 
# The accelerator (GPU) type and count should be set according to 
# the size of the data and number of partitions.

# --accelerator-count should scale with number of partitions in data
# --nvidia-driver-version must match compatible CUDA version
# 

GPU_TYPE="nvidia-tesla-k80" # see: https://cloud.google.com/compute/docs/gpus/
DOCKER_IMAGE="quay.io/broadinstitute/beast-beagle-cuda"

# get absolute path for file
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
SCRIPT="$SCRIPTPATH/$(basename "$SCRIPT")" # absolute path for this script

function print_usage(){
  echo "Usage: "
  echo "  $(basename $0) gs://path/to/in.xml gcp-project-name num_gpus [beagle_order]"
  echo ""
  echo "  Note: The version of BEAST used should match the version of BEAUTi"
  echo "        used to generate the input xml file."
  echo ""
  echo "        Docker images have been built for several versions of BEAST."
  echo "        The Docker image to be used can be selected by the BEAST_VERSION environment variable."
  echo "        For example:"
  echo "          BEAST_VERSION='1.10.4' $(basename $0) gs://path/to/in.xml gcp-project-name num_gpus [beagle_order]"
  echo "        For available versions of BEAST, see the tags on Quay.io:"
  echo "          https://quay.io/repository/broadinstitute/beast-beagle-cuda?tab=tags"
  echo "        If BEAST_VERSION is not specified the 'latest' tag will be used."
  echo ""
  echo "        The GPU type can be set via the BEAST_GPU_MODEL environment variable."
  echo "        For example:"
  echo "          BEAST_GPU_MODEL='nvidia-tesla-v100' $(basename $0) gs://path/to/in.xml gcp-project-name num_gpus [beagle_order]"
  echo "        For available GPU models, see:"
  echo "          https://cloud.google.com/compute/docs/gpus/"
  echo ""
  echo "        If 'beagle_order' is not specified, the number of partitions will be read from"
  echo "        the input xml file and spread across the number of GPUs specified."
  echo "        Note: *the entire xml file will be downloaded from its bucket if 'beagle_order' is not specified*"
  echo ""
  echo "        Extra arguments for BEAST may be passed via the BEAST_EXTRA_ARGS environment variable."
  echo "        For example:"
  echo "          BEAST_EXTRA_ARGS='-beagle_instances 4' $(basename $0) gs://path/to/in.xml gcp-project-name num_gpus [beagle_order]"
}

if [ $# -eq 0 ] || [ $# -lt 3 ]; then
    print_usage
    exit 1
fi

# if the user HAS NOT set the BEAST_VERSION environment variable
# use the latest tagged Docker image
if [[ -z "${BEAST_VERSION}" ]]; then
  DOCKER_IMAGE_TAG=":latest"
else
  DOCKER_IMAGE_TAG=":${BEAST_VERSION}"
fi

# if the user HAS set the BEAST_GPU_MODEL environment variable
if [[ ! -z "${BEAST_GPU_MODEL}" ]]; then
  GPU_TYPE="${BEAST_GPU_MODEL}"
fi

# input args for this script
IN_XML="$1"
OUT_BUCKET="$(dirname $1)"
GCP_PROJECT="$2"
NUM_GPUS="$3"

# if the user HAS NOT specified a beagle_order
# generate one based on the number of GPUs specified
# and the number of partitions in the input XML file
if [ -z "$4" ]; then
  number_of_partitions=$(gsutil cat "$1" | grep "<partition>" | wc -l | awk '{ printf "%d\n", $0 }')

  if [[ ${NUM_GPUS} > ${number_of_partitions} ]]; then
    echo "More GPUs (${NUM_GPUS}) have been requested than there are paritions (${number_of_partitions})."
    echo "Consider reducing the number of GPUs, or specify the 'beagle_order' yourself."
    echo "Exiting..."
    exit 1
  fi

  partition_string=""
  if [[ ${NUM_GPUS} > 0 ]]; then
    partitions_that_fit="$((${number_of_partitions}/${NUM_GPUS}))"
    extra_partitions="$((${number_of_partitions}%${NUM_GPUS}))"

    for i in $(seq 1 ${partitions_that_fit}); do 
      partition_string="${partition_string}$(echo $(seq 1 ${NUM_GPUS})) "
    done
    if [[ ${extra_partitions} > 0 ]]; then
      partition_string="${partition_string} $(echo $(seq 1 ${extra_partitions}))"
    fi
    
  else
    # if no GPUs are specified, set all partitions to be on 
    # resource 0 (CPU)
    for i in $(seq 1 ${number_of_partitions}); do 
      partition_string="${partition_string}0,"
    done
  fi
  partition_string=$(echo "${partition_string}" | sed 's/  / /g' | sed 's/ /,/g' | sed 's/,$//')
  BEAGLE_ORDER="${partition_string}"
else
  BEAGLE_ORDER="$4"
fi

ACCELERATOR_SPEC=""
if [[ ${NUM_GPUS} > 0 ]]; then
  ACCELERATOR_SPEC="--accelerator-type ${GPU_TYPE} --accelerator-count ${NUM_GPUS}"
fi

echo ""
echo "Input file:   ${IN_XML}"
echo "OUT_BUCKET:   ${OUT_BUCKET}"
echo "NUM_GPUs:     ${NUM_GPUS}"
echo "BEAGLE_ORDER: ${BEAGLE_ORDER}"
echo "GPU_TYPE:     ${GPU_TYPE}"
echo "DOCKER_IMAGE: ${DOCKER_IMAGE}${DOCKER_IMAGE_TAG}"
echo "BEAST_EXTRA_ARGS:   ${BEAST_EXTRA_ARGS}"

dsub \
  --provider=google-v2 \
  --project "${GCP_PROJECT}" \
  --zone "us*" \
  --nvidia-driver-version "396.37" \
  --image "${DOCKER_IMAGE}${DOCKER_IMAGE_TAG}" \
  --input "INPUT_FILE=${IN_XML}" \
  --output "OUTPUT_FILES=${OUT_BUCKET}/*" \
  --logging "${OUT_BUCKET}" \
  --env BEAGLE_ORDER="${BEAGLE_ORDER}" BEAST_EXTRA_ARGS="${BEAST_EXTRA_ARGS}" \
  --script "${SCRIPTPATH}/run_beast.sh"  \
  --boot-disk-size 15 \
  "${ACCELERATOR_SPEC}"
  #--wait
