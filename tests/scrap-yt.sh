#!/usr/bin/env bash
# load utility functions
ROOT_DIR=$(realpath "$(dirname "$0")"/..)

source "$ROOT_DIR/transform-av/shared/utils.sh"



# check 'docker' has at least 100 public repos on github
echo "#0 'scrap-yt' with dummy file"
bash "$ROOT_DIR"/download-yt/run -s "$ROOT_DIR"/tests/data/void/hello_world.txt -d tests/data/void >/dev/null || error
echo "#alright!"
