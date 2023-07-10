[ "$(uname)" == "Linux" ] && PYTHON_BIN=python3 || PYTHON_BIN=python

function info() {
  [ -n "$VERBOSE" -o -n "$DEBUG" ] && echo -e "  $1" >&2 || return 0
}

function debug() {
  [ -n "$DEBUG" ] && echo -e "    $1" >&2 || return 0
}

function error() {
  echo "x failed" >&1 && exit 2;
}

function ffmpeg-arch(){
  curl https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-"$1"-gpl"$2" -Lo ffmpeg"$2" 2>/dev/null && \
  $PYTHON_BIN -m "$3" -e ffmpeg"$2" &&\
  "$4" install ffmpeg-master-latest-"$1"-gpl/bin/* /usr/local/bin && \
  rm -r ffmpeg-master-latest-"$1"-gpl ffmpeg"$2"
}

function install-ffmpeg(){
  info "  installing .. ffmpeg"
  OS=$(uname)
  case $OS in
    Linux) ffmpeg-arch "linux64" ".tar.xz" "tarfile" "sudo";;
    Darwin) brew install ffmpeg;;
    [CYGWIN*]|[CYGWIN*]) ffmpeg-arch "win64" ".zip" "zipfile" "";;
    *) info "Don't know how to install 'Ffmpeg"; exit 2;;
  esac
}

function install-package(){
  $PYTHON_BIN -m pip --version > /dev/null 2>/dev/null \
      ||  { info "pip not present. installing .."; curl https://bootstrap.pypa.io/get-pip.py  2>/dev/null | $PYTHON_BIN || exit 2; }
  info "  installing .. '$1'"
  $PYTHON_BIN -m pip install scipy >/dev/null 2>/dev/null || { info "'$1' installation failed"; exit 2; }
}

function dependencies(){
  debug "=> dependencies: checking [ffmpeg/python]"
  ffmpeg -version >/dev/null 2>/dev/null || { info "missing dependency ffmpeg."; install-ffmpeg; }
  $PYTHON_BIN --version | grep -E "Python 3.([1-9]|1[0-1])\..*" >/dev/null \
      ||  { info "Python version is not between 3.0 and 3.11 [detected: $($PYTHON_BIN --version)]"; exit 2; }
}

function dependencies_compute(){
  $PYTHON_BIN -c "import scipy" >/dev/null 2>/dev/null  || { info "missing package 'scipy'."; install-package scypi; }
  $PYTHON_BIN -c "import matplotlib" >/dev/null 2>/dev/null || { info "missing package 'matplotlib'."; install-package matplotlib; }
  $PYTHON_BIN -c "import numpy" >/dev/null 2>/dev/null || { info "missing package 'numpy'."; install-package numpy; }
}

function pre() {
  info "+ into preprocessing"
}

function post() {
  info "+ into postprocessing"
}

function compute() {
  info "+ into compute"
}

function loop() {
  pre
  CWD=$PWD
  directory=$(realpath "$SOURCE_DIRECTORY")
  declare -i total=0
  debug "+ computation loop (do not interrupt)"
  cd "$directory" || exit 2
  for file in $(cd "$directory" && find "." -maxdepth 1 -iname "*$1"); do
    [ -n "$file" ] && compute "$file" && ((total++))
  done || cd "$CWD"
  echo "{\"total\": $total}"
  post
}


#Compute Palindromic FFT
function loop-compute-p() {
  #Compute reverted audio files
  audio_files=$(realpath "$SOURCE_DIRECTORY")
  local root_dir
  root_dir=$(realpath "$(dirname "$0")")
  debug "=> reverting audio files"
  bash "$root_dir"/../reverse/run -s "$audio_files" > /dev/null
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
      if [[ "$COMPUTE_METHOD" == @("expensive"|"reverse") ]]; then
        $PYTHON_BIN "$root_dir/../shared/scripts.py" fft \
        -a "$audio_files/$filename" "$audio_files/.reversed/${filename,,}" "$audio_files/.palindromic/${filename,,}"  \
        -o "$audio_files/.fft/${filename,,}.png" && ((total++))
      else
        $PYTHON_BIN "$root_dir/../shared/scripts.py" fft \
        -a "$audio_files/$filename" -o "$audio_files/.fft/${filename,,}.png" && ((total++))
      fi
  done <<< "$list"
  echo "{\"total\": $total}"
  [[ "$COMPUTE_METHOD" == "expensive" ]] && { cd "$audio_files" && wipe-chops; } || true
}

#Compute Fractal FFT
function loop-compute-f() {
  source "$(dirname "$0")/../shared/preprocess.sh"
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
      $PYTHON_BIN "$root_dir/../shared/scripts.py" fft -a "${files[@]/$'\n'}"  -o "$audio_files/.fft/${filename,,}.png" && ((total++))
      cd "$audio_files" && wipe-chops || true
  done <<< "$list"
  echo "{\"total\": $total}"
}

