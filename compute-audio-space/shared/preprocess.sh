function replace() {
    [ ! -f "$1" ] && return 0
    [ "$1" != "$2" ] && debug "-- editing file $1" && mv "$1" "$2"
}

function to-lowercase() {
  lowercase_name=${1,,}
  clean_name="${lowercase_name//[\ \'\(\)]/_}"
  debug "++ check naming: current=$1, expected=$clean_name"
  replace "$1" "$clean_name" >/dev/null
}

function preprocess(){
  audio_audios=$(realpath "$SOURCE_DIRECTORY")
  CWD=$PWD
  #Converting MP3/OGG audios to wav
  debug "=> preprocess: checking MP3/OGG"
  MP3=$(cd "$audio_audios" && find "." -maxdepth 1 -iname '*.mp3' -o -iname '*.ogg' -o -iname '*.m4a')
  [ -n "$MP3" ] && {
    debug "+ converting MP3/OGG"
    for file in ${MP3[*]}; do
      {  ffmpeg -y -i "$audio_audios/$file" "$audio_audios/${file##*/}.wav" >/dev/null 2>/dev/null  ; }
    done || { cd "$CWD" && exit 2; }
  }
  debug "=> preprocess: checking audio audios"
  cd "$audio_audios" || exit 2
  local list
  list=$(find "." -maxdepth 1 -iname '*.wav')
  [ -z "$list" ] && debug "x no audio audios found" && exit 0
  debug "+ audio file(s) found"
  debug "+ checking special characters"
  while read -r filename; do
      to-lowercase "$filename"
  done <<< "$list"
  cd "$CWD" || exit 2
  #chop audio file to check fractal conservation (method==expensive)
  [[ "$COMPUTE_METHOD" == @("expensive"|"fractal") ]] && chop-audio-audios
}

function chop(){
  readarray audios <<< "$@"
  file1=${audios[0]/$'\n'}
  file2=${audios[1]/$'\n'}
  t0=$(ffprobe -i "$file1" -show_entries format=duration -v quiet -of csv="p=0")
  t1=$(awk "BEGIN {print $t0/2.0}")
  debug "+ chopping: $file1 ($t0->$t1)"
  ffmpeg -nostdin -y -i "$file1" -ss 0 -to "$t1" -c copy "$file2" >/dev/null 2>/dev/null \
    || { info "x chop '$file1' failed" ; exit 2; }
}

function wipe-chops(){
  debug "-- clearing old '.y.wav'"
  old_chopped=$(find "." -maxdepth 1 -iname '*.y.wav')
  [ -z "$old_chopped" ] && return 0
  local filename
  while read -r filename; do
      rm "$filename"
  done <<< "$old_chopped"
}

function yy() {
  for ((i=1; i<=$1; i++)); do echo -n '.y'; done
}

function chop-audio-audios(){
  audio_audios=$(realpath "$SOURCE_DIRECTORY")
  debug "=> chopping audio audios"
  cd "$audio_audios" || exit 2
  wipe-chops
  local list
  list=$(find "." -maxdepth 1 -iname '*.wav')
  [ "${#list[@]}" -eq 0 ] && debug "x no audio audios found" && exit 0
  debug "+ audio file(s) found"
  debug "${list[*]}"
  debug "+ chopping audio file(s)"
  local filename
  while read -r filename; do
    [ -z "$filename" ] && continue
    debug "+ original: $filename"
    for i in $(seq 1 "$FRACTAL_LEVEL"); do
      chop "$(for ((j=$((i-1)); j<="$i"; j++)); do echo "${filename//.wav/$(yy "$j").wav}"; done)" || exit 2
    done
  done <<< "${list[@]}"
  cd "$CWD" || exit 2
}
