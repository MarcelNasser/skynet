while getopts :s:l:v:m:e: flag
do
    case "${flag}" in
        s) SOURCE_DIRECTORY=${OPTARG};;
        l) FRACTAL_LEVEL=${OPTARG};;
        m) MOVE_CHOPS=${OPTARG};;
        v) VERBOSE=${OPTARG};;
        e) EXT=${OPTARG};;
        *)
          usage
          exit 0
          ;;
    esac
done

FRACTAL_LEVEL=${FRACTAL_LEVEL:-1}
VERBOSE=${VERBOSE:-true}
MOVE_CHOPS=${MOVE_CHOPS:-yes}
EXT=${EXT:-.y}

! [ -n "$SOURCE_DIRECTORY" -a -d "$SOURCE_DIRECTORY" ] && echo "*Directory not found*" && usage && exit 2

info "* Source(s) Directory: $SOURCE_DIRECTORY"
info "* Chopping Level: $FRACTAL_LEVEL"
info "* Move Chops [yes/no]: $MOVE_CHOPS"