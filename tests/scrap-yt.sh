#!/usr/bin/env bash
# load utility functions
ROOT_DIR="$(dirname "$0")"

source "$ROOT_DIR/../transform-av/shared/utils.sh"



# check 'docker' has at least 100 public repos on github
echo "#0 'scrap-yt' with dummy file"
bash download-yt/run -s tests/data/void/hello_world.txt -d tests/data/void >/dev/null || error
echo "#alright!"
