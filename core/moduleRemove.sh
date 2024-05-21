modulename="$2"
! [[ -f "core/modules/confs/$modulename.conf" ]] && errorlog "Module conf not found!" && sublog "/opt/PHT/core/modules/confs/$modulename.conf" && exit 1

confindex "core/modules/confs/$modulename.conf"

if [[ $(docker ps -as | grep "$name") =~ ("Up"|"up") ]]; then
    if [[ $(docker ps -as | grep "$id" | awk '{print $1}') != "$id" ]]; then
        errorlog "Docker ID not match!"
        sublog "Reference ID -> $id"
        exit 1
    fi
    startanimation "Shutdown $name"
    docker stop $id &>/dev/null && (stopanimation "done") || (stopanimation "error" && exit 1)
fi
startanimation "Remove $name"
rm core/modules/confs/$modulename.conf || (stopanimation "error" && errorlog "Conf can not removed!" && sublog "PATH -> /opt/PHT/core/modules/confs/$modulename.conf" && exit 1)
rm -r core/modules/$modulename || (stopanimation "error" && errorlog "Module Path can not removed!" && sublog "PATH -> /opt/PHT/core/modules/$modulename" && exit 1)
docker remove $id &>/dev/null || (stopanimation "error" && errorlog "Container can not removed!" && sublog "Reference ID -> $id" && exit 1)
stopanimation "done"
infolog "Module $name removed."
exit 0
