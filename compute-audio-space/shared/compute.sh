#Compute Palindromic FFT
function compute-p() {
  #Compute reverted audio files
  audio_files=$(realpath "$SOURCE_DIRECTORY")
  local root_dir
  root_dir=$(realpath "$(dirname "$0")")
  debug "=> reverting audio files"
  bash "$root_dir"/../transform-av/reverse/run -s "$audio_files" > /dev/null
  #Compute FFT of original / reverted / palindromic audio file
  debug "=> fft audio files"
  [ -d "$audio_files/.fft/" ] && { debug "+ clearing .fft directory"; rm -r "$audio_files/.fft/"; }
  mkdir "$audio_files/.fft/"
  declare -i total=0
  local list
  list=$(cd "$audio_files" && find "." -maxdepth 1 -iname '*.wav')
  debug "=> computation loop (p)";
  while read -r filename; do
      [ -z "$filename" ] && continue
      debug "++ file #$total: $filename"
      python3 "$root_dir/shared/scripts.py" fft \
      -a "$audio_files/$filename" "$audio_files/.reversed/${filename,,}" "$audio_files/.palindromic/${filename,,}"  \
      -o "$audio_files/.fft/${filename,,}.png" && ((total++))
      [[ "$COMPUTE_METHOD" == "expensive" ]] && { cd "$audio_files" && wipe-chops; } || true
  done <<< "$list" && echo "{\"total\": $total}"
}

#Compute Fractal FFT
function compute-f() {
  source "$(dirname "$0")/shared/preprocess.sh"
  audio_files=$(realpath "$SOURCE_DIRECTORY")
  #Compute FFT of original / chop #1 / chop #2 ...
  local root_dir
  root_dir=$(realpath "$(dirname "$0")")
  debug "=> fft audio files"
  [ -d "$audio_files/.fft/" ] && { debug "-- clearing .fft directory"; rm -r "$audio_files/.fft/"; }
  mkdir "$audio_files/.fft/"
  declare -i total=0
  local list
  list=$(cd "$audio_files" && find "." -maxdepth 1 -iname '*.wav' -a ! -iname '*.y.wav'  )
  debug "=> computation loop (f)";
  while read -r filename; do
      [ -z "$filename" ] && continue
      for i in $(seq 1 "$FRACTAL_LEVEL"); do
        chop "$(for ((j=$((i-1)); j<="$i"; j++)); do echo "$audio_files/${filename//.wav/$(yy "$j").wav}"; done)" || exit 2
      done
      readarray files <<< "$(for ((j="$FRACTAL_LEVEL"; j>=0; j--)); do echo "$audio_files/${filename//.wav/$(yy "$j").wav}"; done)"
      debug "++ file #$total: $filename"
      python3 "$root_dir/shared/scripts.py" fft -a "${files[@]/$'\n'}"  -o "$audio_files/.fft/${filename,,}.png" && ((total++))
      cd "$audio_files" && wipe-chops || true
  done <<< "$list" && echo "{\"total\": $total}"
}
