#!/usr/bin/env bash
# computation of fourier graph with sub-slicing

# load utility functions
source "$(dirname "$0")/../transform-av/shared/utils.sh"
source "$(dirname "$0")/../transform-av/shared/preprocess.sh"

ROOT_DIR="$(dirname "$0")/.."

echo "#0 'compute-audio-space' single audio [expensive]"
bash "$ROOT_DIR"/transform-av/compute/run -s "$ROOT_DIR"/tests/data/audio/single-file -m expensive -l 1 >/dev/null || error "compute crash"
check_content "$ROOT_DIR"/tests/data/audio/single-file/.fft/expensive 'image/png'
check_content "$ROOT_DIR"/tests/data/audio/single-file/.palindromic 'audio/x-wav'
check_content "$ROOT_DIR"/tests/data/audio/single-file/.reversed 'audio/x-wav'
[ "$(find "$ROOT_DIR/tests/data/audio/single-file/.fft/expensive" -maxdepth 1 -iname '*.png'| wc -l)" -ne 2 ] && echo "number of fft [expensive] <> 2" && error

echo "#1 'compute-audio-space' single audio [fractal]"
bash "$ROOT_DIR"/transform-av/compute/run -s "$ROOT_DIR"/tests/data/audio/single-file -m fractal -l 1 >/dev/null || error "compute crash"
check_content "$ROOT_DIR"/tests/data/audio/single-file/.fft/fractal 'image/png'
[ "$(find "$ROOT_DIR/tests/data/audio/single-file/.fft/fractal" -maxdepth 1 -iname '*.png'| wc -l)" -ne 1 ] && echo "number of fft [fractal] <> 1" && error

echo "#2 'compute-audio-space' multiple audio(s)"
bash "$ROOT_DIR"/transform-av/compute/run -s "$ROOT_DIR"/tests/data/audio/multiple-files -m reverse >/dev/null || error "compute crash"
check_content "$ROOT_DIR"/tests/data/audio/multiple-files/.fft/reverse 'image/png'
check_content "$ROOT_DIR"/tests/data/audio/multiple-files/.palindromic 'audio/x-wav'
check_content "$ROOT_DIR"/tests/data/audio/multiple-files/.reversed 'audio/x-wav'

echo "#alright!"
