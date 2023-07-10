while getopts :s:l:v: flag
do
    case "${flag}" in
        s) SOURCE_DIRECTORY=${OPTARG};;
        l) FRACTAL_LEVEL=${OPTARG};;
        v) VERBOSE=${OPTARG};;
        *)
          usage
          exit 0
          ;;
    esac
done

FRACTAL_LEVEL=${FRACTAL_LEVEL:-1}
VERBOSE=${VERBOSE:-TRUE}

! [ -n "$SOURCE_DIRECTORY" -a -d "$SOURCE_DIRECTORY" ] && echo "*Directory not found*" && usage && exit 2

info "* Source(s) Directory: $SOURCE_DIRECTORY"
info "* Fractal Level: $FRACTAL_LEVEL"