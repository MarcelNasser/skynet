function replace() {
    [ ! -f "$1" ] && return 0 || true
    [ "$1" != "$2" ] && debug "-- editing file $1" && mv "$1" "$2" || true
}

function to-lowercase() {
  lowercase_name=${1,,}
  clean_name="${lowercase_name//[\ \'\(\)]/_}"
  debug "++ check naming: current=$1, expected=$clean_name"
  replace "$1" "$clean_name" >/dev/null
  echo "$clean_name"
}


function preprocess(){
  local directory
  directory=$(realpath "$SOURCE_DIRECTORY")
  CWD=$PWD
  #Converting MP3/OGG audios to wav
  debug "=> preprocess: checking MP3/OGG"
  MP3=$(cd "$directory" && find "." -maxdepth 1 -iname '*.mp3' -o -iname '*.ogg' -o -iname '*.m4a' -o -iname '*.flac')
  [ -n "$MP3" ] && {
    debug "+ converting MP3/OGG"
    mkdir -p "$directory/.orig/"
    for file in ${MP3[*]}; do
      {  ffmpeg -y -i "$directory/$file" "$directory/${file##*/}.wav" >/dev/null 2>/dev/null  ; \
         mv "$directory/$file" "$directory/.orig/" ; }
    done || { cd "$CWD" && exit 2; }
  }
  debug "=> preprocess: checking audio audios"
  cd "$directory" || exit 2
  local list
  list=$(find "." -maxdepth 1 -iname '*.wav' -o -iname '*.mp4')
  [ -z "$list" ] && info "x no av files found" && exit 0
  debug "+ audio file(s) found"
  debug "+ checking special characters"
  while read -r filename; do
      to-lowercase "$filename"
  done <<< "$list"
  cd "$CWD" || exit 2
  #chop audio file to check fractal conservation (method==expensive)
  [[ "$COMPUTE_METHOD" == @("fractal") ]] && {
    debug "=> preprocess: chopping loop"
    bash "$ROOT_DIR/../chop/run" -s "$SOURCE_DIRECTORY" -l "$FRACTAL_LEVEL" -m "yes"  >/dev/null || error "chopping of fractal crashed"
  }
}

function chop(){
  readarray audios <<< "$@"
  file1=${audios[0]/$'\n'}
  file2=${audios[1]/$'\n'}
  t0=$(ffprobe -i "$file1" -show_entries format=duration -v quiet -of csv="p=0" 2>/dev/null)
  debug "+ chopping: $file1 [$t0]"
  t1=$(awk "BEGIN {print $t0/2.0}"| sed s/,/./)
  debug "+ chopping: $file1 [$t0->$t1]"
  ffmpeg -nostdin -loglevel panic -y -i "$file1" -ss 0 -to "$t1" -c copy "$file2" >/dev/null  \
    || { info "x chop '$file1' failed" ; exit 2; }
}

function wipe-chops(){
  ext=${EXT:-.y}
  debug "-- clearing old $ext.wav"
  old_chopped=$(find "." -maxdepth 1 -iname "*$ext.wav")
  [ -z "$old_chopped" ] && return
  local filename
  while read -r filename; do
      rm "$filename"
  done <<< "$old_chopped"
}

function yy() {
  ext=${EXT:-.y}
  for ((i=1; i<=$1; i++)); do echo -n "$ext"; done
}

function xx() {
  for ((i=1; i<=$1; i++)); do echo -n '.x'; done
}

# check if all files in a directory are of a certain type
function check_content(){
  LIST=$(find "$1" -maxdepth 1 -type f)
  [ -z "$LIST" ] && error "empty folder '$1'"
  while read -r file; do
    if ! echo "${@:2}" | grep -q "$(file -b --mime-type "$file")"; then
      error "$file is not of type $2"
    fi
  done <<< "$LIST"
}
