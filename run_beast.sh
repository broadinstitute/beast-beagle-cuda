#!/bin/bash

# This script is intended to invoke beast within a Docker container
# running on the Google Cloud Platform via the Pipelines API / dsub

IN_DIR=$(dirname "${INPUT_FILE}")
OUT_DIR=$(dirname "${OUTPUT_FILES}")
OUTPUT_PREFIX=$(basename "${INPUT_FILE}" .xml)

pwd 
cd $OUT_DIR
beast -beagle_info > "${OUTPUT_PREFIX}.out"
pwd 
beast -beagle_GPU -beagle_cuda -beagle_double -beagle_scaling always -beagle_order 1 ${INPUT_FILE} >> "${OUTPUT_PREFIX}.out"
ls 
