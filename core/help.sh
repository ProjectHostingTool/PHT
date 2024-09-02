shift
if ! [[ -z $1 ]]; then
    for parameter in $@; do
        case $parameter in
            "commands")  source core/help/commands.sh  ;;
            *) log.warn "Unkown parameter: $parameter"  ;;
        esac
    done
else
    source core/help/commands.sh
fi