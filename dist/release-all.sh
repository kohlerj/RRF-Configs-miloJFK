#!/usr/bin/env bash

# Get directory of this script
SD=$(dirname "$0")

# Include common variables
source ${SD}/release-common.env

# Source build function
source ${SD}/functions.sh

# Create cache dir so we don't download
# the same files for each release.
make_cache_dir

ENABLE_RNOTES="aww yiss"

rm "${RNOTES_PATH}"

get_header

# Build the release package for this machine
load_release "milo-v1.5" "ldo-kit-fly-cdyv3"
build_release

load_release "milo-v1.5" "reference-fly-cdyv3"
build_release

load_release "milo-v1.5" "reference-skr3-ez-5160"
build_release

load_release "milo-v1.5" "milojfk-skr3-ez-h743-5160"
build_release

clean_cache_dir