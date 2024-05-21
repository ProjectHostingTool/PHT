shift
if ! [[ -z $1 ]]; then
    for parameter in $@; do
        case $parameter in
            "commands")  source core/help/commands.sh  ;;
            *) warnlog "Unkown parameter: $parameter"  ;;
        esac
    done
else
    errorlog "You must set parameter! Ex: pht help commands"
fi