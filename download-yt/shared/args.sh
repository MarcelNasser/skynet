while getopts :s:d: flag
do
    case "${flag}" in
        s) URLS=${OPTARG};;
        d) DIRECTORY=${OPTARG};;
        *)
          usage
          exit 0
          ;;
    esac
done

# shellcheck disable=SC2166
! [ -n "$URLS" -a -f "$URLS" ] && usage && echo "*Urls file not found*" && exit 2
# shellcheck disable=SC2166
! [ -n "$DIRECTORY" -a -d "$DIRECTORY" ] && usage && echo "*Directory not given*" && exit 2
