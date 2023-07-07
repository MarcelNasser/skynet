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
  $PYTHON_BIN -c "import scipy" >/dev/null 2>/dev/null  || { info "missing package 'scipy'."; install-package scypi; }
  $PYTHON_BIN -c "import matplotlib" >/dev/null 2>/dev/null || { info "missing package 'matplotlib'."; install-package matplotlib; }
  $PYTHON_BIN -c "import numpy" >/dev/null 2>/dev/null || { info "missing package 'numpy'."; install-package numpy; }
}

