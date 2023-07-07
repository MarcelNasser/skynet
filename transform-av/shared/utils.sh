[ "$(uname)" == "Linux" ] && PYTHON_BIN=python3 || PYTHON_BIN=python

function info() {
  [ -n "$VERBOSE" -o -n "$DEBUG" ] && echo -e "  $1" >&2 || return 0
}

function debug() {
  [ -n "$DEBUG" ] && echo -e "    $1" >&2 || return 0
}

function ffmpeg-arch(){
  curl https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-"$1"-gpl"$2" -Lo ffmpeg"$2" 2>/dev/null && \
  $PYTHON_BIN -m "$3" -e ffmpeg"$2" &&\
  "$4" install ffmpeg-master-latest-"$1"-gpl/bin/* /usr/local/bin && \
  rm -r ffmpeg-master-latest-"$1"-gpl ffmpeg"$2"
}

function install-ffmpeg(){
  OS=$(uname)
  case $OS in
    Linux) ffmpeg-arch "linux64" ".tar.xz" "tarfile" "sudo";;
    Darwin) brew install ffmpeg;;
    [CYGWIN*]|[CYGWIN*]) ffmpeg-arch "win64" ".zip" "zipfile" "";;
    *) info "Do know how to install 'Ffmpeg"; exit 2;;
  esac
}

function dependencies(){
  info "+ dependencies: checking [ffmpeg/python]"
  ffmpeg -version >/dev/null 2>/dev/null || { info "missing dependency ffmpeg. installing .."; install-ffmpeg; }
  $PYTHON_BIN --version | grep -E "Python 3.([1-9]|1[0-1])\..*" >/dev/null \
      ||  { info "Python version is not between 3.0 and 3.11 [detected: $($PYTHON_BIN --version)]"; exit 2; }
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
  info "+ computation loop (do not interrupt)"
  #Reversion Loop
  cd "$directory" || exit 2
  for file in $(cd "$directory" && find "." -maxdepth 1 -iname "*$1"); do
    [ -n "$file" ] && compute "$file" && ((total++))
  done || cd "$CWD"
  echo "{\"total\": $total}"
  post
}

