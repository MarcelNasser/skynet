#!/usr/bin/env bash
# computation of fourier graph with sub-slicing

# load utility functions
source "$(dirname "$0")/../transform-av/shared/preprocess.sh"
source "$(dirname "$0")/../transform-av/shared/utils.sh"

ROOT_DIR="$(dirname "$0")"/..

echo "#0 'chop' single audio"
bash "$ROOT_DIR"/transform-av/chop/run -s "$ROOT_DIR"/tests/data/audio/single-file -l 2 || error
[ "$(find "$ROOT_DIR/tests/data/audio/single-file/.chopped" -maxdepth 1 -iname '*.y.wav'| wc -l)" -ne 2 ] && echo "number of chops <> 2" && error

echo "#1 'interpolate' single audio"
bash "$ROOT_DIR"/transform-av/interpolate/run -s "$ROOT_DIR"/tests/data/audio/single-file/.chopped -l 2  || error
[ "$(find "$ROOT_DIR/tests/data/audio/single-file/.chopped/.interpolated" -maxdepth 1 -iname '*.x.wav'| wc -l)" -ne 2 ] && echo "number of interpolates <> 2" && error

rm -r "$ROOT_DIR/tests/data/audio/single-file/.chopped/"

echo "#alright!"
