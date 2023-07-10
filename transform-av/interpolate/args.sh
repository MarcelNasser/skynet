while getopts :s:l:v:m: flag
do
    case "${flag}" in
        s) SOURCE_DIRECTORY=${OPTARG};;
        m) INT_METHOD=${OPTARG};;
        l) MULTIPLY_FACTOR=${OPTARG};;
        v) VERBOSE=${OPTARG};;
        *)
          usage
          exit 0
          ;;
    esac
done

MULTIPLY_FACTOR=${MULTIPLY_FACTOR:-2}
VERBOSE=${VERBOSE:-TRUE}
INT_METHOD=${INT_METHOD:-linear}

! [ -n "$SOURCE_DIRECTORY" -a -d "$SOURCE_DIRECTORY" ] && echo "*Directory not found*" && usage && exit 2
! [[ "$INT_METHOD" == @("linear"|"zeros") ]] && echo "*interpolation method '$INT_METHOD' not valid*" && usage && exit 2

info "* Source(s) Directory: $SOURCE_DIRECTORY"
info "* Multiply Factor: $MULTIPLY_FACTOR"
info "* Interpolation Method: $INT_METHOD"