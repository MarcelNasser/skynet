#!/usr/bin/env bash
# compute fourier transform graph

# load utility functions
source "$(dirname "$0")/../transform-av/shared/utils.sh"
source "$(dirname "$0")/../transform-av/shared/preprocess.sh"

ROOT_DIR=$(realpath "$(dirname "$0")/..")

echo "#1 'compute-audio-space' single audio"
bash "$ROOT_DIR"/transform-av/compute/run -s "$ROOT_DIR"/tests/data/audio/single-file -m reverse || error
check_content "$ROOT_DIR"/tests/data/audio/single-file/.fft/reverse 'image/png'
check_content "$ROOT_DIR"/tests/data/audio/single-file/.palindromic 'audio/x-wav'
check_content "$ROOT_DIR"/tests/data/audio/single-file/.reversed 'audio/x-wav'

echo "#2 'compute-audio-space' pathologic file(s)"
mv "$ROOT_DIR"/tests/data/audio/special-cases/a_a_a.wav "$ROOT_DIR/tests/data/audio/special-cases/a'a a.wav" || error
bash "$ROOT_DIR"/transform-av/compute/run -s "$ROOT_DIR"/tests/data/audio/special-cases -m reverse || error
check_content "$ROOT_DIR"/tests/data/audio/special-cases/.fft/reverse 'image/png'
check_content "$ROOT_DIR"/tests/data/audio/special-cases/.palindromic 'audio/x-wav'
check_content "$ROOT_DIR"/tests/data/audio/special-cases/.reversed 'audio/x-wav'
echo "#alright!"
