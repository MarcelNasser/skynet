#!/usr/bin/env bash
# check transform-av/reverse

# load utility functions
source "$(dirname "$0")/../transform-av/shared/utils.sh"
source "$(dirname "$0")/../transform-av/shared/preprocess.sh"

ROOT_DIR=$(realpath "$(dirname "$0")"/..)

echo "#0 'reverse' single audio"
bash "$ROOT_DIR"/transform-av/reverse/run -s "$ROOT_DIR"/tests/data/audio/single-file  || error
check_content "$ROOT_DIR"/tests/data/audio/single-file/.reversed 'audio/x-wav'

echo "#1 'reverse' single audio a second time"
bash "$ROOT_DIR"/transform-av/reverse/run -s "$ROOT_DIR"/tests/data/audio/single-file/.reversed  || error
check_content "$ROOT_DIR"/tests/data/audio/single-file/.reversed/.reversed 'audio/x-wav'

echo "#2 'reverse' checksums checkouts"
sum0=$(ffmpeg -i "$ROOT_DIR"/tests/data/audio/single-file/*.wav -f hash - 2>/dev/null |cut -d '=' -f2)
sum1=$(ffmpeg -i "$ROOT_DIR"/tests/data/audio/single-file/.reversed/*.wav  -f hash - 2>/dev/null |cut -d '=' -f2)
sum2=$(ffmpeg -i "$ROOT_DIR"/tests/data/audio/single-file/.reversed/.reversed/*.wav -f hash - 2>/dev/null |cut -d '=' -f2)
if [ "$sum0" == "$sum1" ]; then echo "original and reverse are identical"; error; fi
if [ "$sum0" != "$sum2" ]; then echo "original and reverse(reverse) are not identical"; error; fi
echo "#alright!"
