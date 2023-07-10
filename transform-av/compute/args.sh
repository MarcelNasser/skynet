while getopts :m:s:l:v: flag
do
    case "${flag}" in
        m) COMPUTE_METHOD=${OPTARG};;
        s) SOURCE_DIRECTORY=${OPTARG};;
        l) FRACTAL_LEVEL=${OPTARG};;
        v) VERBOSE=${OPTARG};;
        *)
          usage
          exit 0
          ;;
    esac
done

COMPUTE_METHOD=${COMPUTE_METHOD:-reverse}
FRACTAL_LEVEL=${FRACTAL_LEVEL:-2}
VERBOSE=${VERBOSE:-TRUE}

! [ -n "$SOURCE_DIRECTORY" -a -d "$SOURCE_DIRECTORY" ] && echo "*Directory not found*" && usage && exit 2

info "* Compute Method: $COMPUTE_METHOD"
info "* Source(s) Directory: $SOURCE_DIRECTORY"
[[ "$COMPUTE_METHOD" == @("expensive"|"fractal") ]]  && info "* Fractal Level: $FRACTAL_LEVEL"