#!/bin/bash

# This script is intended to invoke beast within a Docker container
# running on the Google Cloud Platform via the Pipelines API / dsub

IN_DIR=$(dirname "${INPUT_FILE}")
OUT_DIR=$(dirname "${OUTPUT_FILES}")
OUTPUT_PREFIX=$(basename "${INPUT_FILE}" .xml)
if [ -z "${BEAGLE_ORDER}" ]; then
  BEAGLE_ORDER=1 # run on first GPU only if BEAGLE_ORDER is not set
fi

if [ -z "${INPUT_FILE}" ]; then
    echo "Usage: $(basename $0) [beagle_order]"
    echo '       The input xml must be passed via INPUT_FILE=/path/to/beauti_generated_input.xml'
    exit 1
fi

pwd 
cd $OUT_DIR
beast -beagle_info > "${OUTPUT_PREFIX}.out"
pwd 
beast -beagle_multipartition off -beagle_GPU -beagle_cuda -beagle_double -beagle_scaling always -beagle_order ${BEAGLE_ORDER} ${BEAST_EXTRA_ARGS} ${INPUT_FILE} >> "${OUTPUT_PREFIX}.out"
ls 
