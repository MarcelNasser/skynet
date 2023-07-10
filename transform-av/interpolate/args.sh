while getopts :s:f:v: flag
do
    case "${flag}" in
        s) SOURCE_DIRECTORY=${OPTARG};;
        f) MULTIPLY_FACTOR=${OPTARG};;
        v) VERBOSE=${OPTARG};;
        *)
          usage
          exit 0
          ;;
    esac
done

MULTIPLY_FACTOR=${MULTIPLY_FACTOR:-2}
VERBOSE=${VERBOSE:-TRUE}

! [ -n "$SOURCE_DIRECTORY" -a -d "$SOURCE_DIRECTORY" ] && echo "*Directory not found*" && usage && exit 2

info "* Source(s) Directory: $SOURCE_DIRECTORY"
info "* Multiply Factor: $MULTIPLY_FACTOR"