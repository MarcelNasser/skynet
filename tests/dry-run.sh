#!/usr/bin/env bash
# Test scripts are no making any harm for a dry run

# load utility functions
source "$(dirname "$0")/../transform-av/shared/utils.sh"

# initial checksum
# shellcheck disable=SC2012
checksum_1=$(find tests/data/void/ -type f | md5sum|cut -d ' ' -f1)
echo "#1 dry run of 'compute-audio-space'"
bash transform-av/compute/run -s tests/data/void >/dev/null  || error
echo "#2 dry run of 'browse-github'"
bash browse-github/run -o xxx >/dev/null 2>/dev/null || error
echo "#3 dry run of 'reverse-audio'"
bash transform-av/reverse/run -s tests/data/void >/dev/null || error
echo "#4 dry run of 'downsize-video'"
bash transform-av/downsize/run -s tests/data/void >/dev/null || error
echo "#5 dry run of 'chop-audio'"
bash transform-av/chop/run -s tests/data/void -l 10 >/dev/null || error
echo "#6 dry run of 'interpolate-audio'"
bash transform-av/interpolate/run -s tests/data/void -l 2 >/dev/null || error
echo "#7 dry run of 'download-audio'"
bash download-yt/run -s tests/data/void/void -d tests/data/void >/dev/null || error
echo "#N check files checksums"
# shellcheck disable=SC2012
# final checksum
checksum_2=$(find tests/data/void/ -type f | md5sum|cut -d ' ' -f1)
[ -n "$DEBUG" ] && echo -e "  * checksum #1=$checksum_1 \n  * checksum #2=$checksum_2"
[ "$checksum_1" != "$checksum_2" ] && error
echo "#alright!"
