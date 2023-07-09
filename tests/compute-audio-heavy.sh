#!/usr/bin/env bash
# computation of fourier graph with sub-slicing

# load utility functions
source "$(dirname "$0")/utils.sh"

ROOT_DIR="$(dirname "$0")"/..

FRACTALS=1

echo "#0 'compute-audio-space' single audio [expensive]"
bash "$ROOT_DIR"/compute-audio-space/run -s "$ROOT_DIR"/tests/data/audio/single-file -m expensive -l $FRACTALS >/dev/null || error
check_content "$ROOT_DIR"/tests/data/audio/single-file/.fft 'image/png'
check_content "$ROOT_DIR"/tests/data/audio/single-file/.palindromic 'audio/x-wav'
check_content "$ROOT_DIR"/tests/data/audio/single-file/.reversed 'audio/x-wav'
[ "$(find "$ROOT_DIR/tests/data/audio/single-file/.fft" -maxdepth 1 -iname '*.png'| wc -l)" -ne 1 ] && echo "number of fft [expensive] <> 1" && error

echo "#1 'compute-audio-space' single audio [fractal]"
bash "$ROOT_DIR"/compute-audio-space/run -s "$ROOT_DIR"/tests/data/audio/single-file -m fractal -l $FRACTALS >/dev/null || error
check_content "$ROOT_DIR"/tests/data/audio/single-file/.fft 'image/png'
[ "$(find "$ROOT_DIR/tests/data/audio/single-file/.fft" -maxdepth 1 -iname '*.png'| wc -l)" -ne 1 ] && echo "number of fft [fractal] <> 1" && error

echo "#2 'compute-audio-space' multiple audio(s)"
bash "$ROOT_DIR"/compute-audio-space/run -s "$ROOT_DIR"/tests/data/audio/multiple-files >/dev/null || error
check_content "$ROOT_DIR"/tests/data/audio/multiple-files/.fft 'image/png'
check_content "$ROOT_DIR"/tests/data/audio/multiple-files/.palindromic 'audio/x-wav'
check_content "$ROOT_DIR"/tests/data/audio/multiple-files/.reversed 'audio/x-wav'

echo "#alright!"
