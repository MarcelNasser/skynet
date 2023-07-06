#Compute Palindromic FFT
function compute-p() {
  #Compute reverted audio files
  audio_files=$(realpath "$SOURCE_DIRECTORY")
  local root_dir
  root_dir=$(realpath "$(dirname "$0")")
  info "=> reverting audio files"
  bash "$root_dir"/../reverse-audio/run -s "$audio_files"

  #Compute FFT of original / reverted / palindromic audio file
  info "=> fft audio files"
  [ -d "$audio_files/.fft/" ] && { debug "+ clearing .fft directory"; rm -r "$audio_files/.fft/"; }
  mkdir "$audio_files/.fft/"
  declare -i TOTAL=0
  local list
  list=$(cd "$audio_files" && find "." -maxdepth 1 -iname '*.wav')
  info "=> entering computation loop";
  while read -r filename; do
      {  info "++ file #$TOTAL: $filename"\
      && python3 "$root_dir/shared/scripts.py" fft -a "$audio_files/$filename" "$audio_files/.reversed/${filename,,}" "$audio_files/.palindromic/${filename,,}" -o "$audio_files/.fft/${filename,,}.png" \
           && TOTAL=$TOTAL+1 ; }
  done <<< "$list" && echo "total computed: $TOTAL"
}

#Compute Fractal FFT
function compute-f() {
  audio_files=$(realpath "$SOURCE_DIRECTORY")
  #Compute FFT of original / chop #1 / chop #2 ...
  local root_dir
  root_dir=$(realpath "$(dirname "$0")")
  info "=> fft audio files"
  [ -d "$audio_files/.fft/" ] && { debug "-- clearing .fft directory"; rm -r "$audio_files/.fft/"; }
  mkdir "$audio_files/.fft/"
  declare -i TOTAL=0
  local list
  list=$(cd "$audio_files" && find "." -maxdepth 1 -iname '*.wav' -a ! -iname '*.y.wav'  )
  info "=> entering computation loop";
  while read -r filename; do
      { readarray files <<< "$(for ((j="$FRACTAL_LEVEL"; j>=0; j--)); do echo "$audio_files/${filename//.wav/$(yy "$j").wav}"; done)";
        info "++ file #$TOTAL: $filename"\
      && python3 "$root_dir/shared/scripts.py" fft -a "${files[@]/$'\n'}"  -o "$audio_files/.fft/${filename,,}.png" \
           && TOTAL=$TOTAL+1; }
  done <<< "$list" && echo "total computed: $TOTAL"
}