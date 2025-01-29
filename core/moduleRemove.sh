modulename="$2"
! [[ -f "core/modules/confs/$modulename.conf" ]] && log.error "Module conf not found!" && log.sub "/opt/PHT/core/modules/confs/$modulename.conf" && exit 1

confindex "core/modules/confs/$modulename.conf"

if [[ $(docker ps -as | grep "$name") =~ ("Up"|"up") ]]; then
    if [[ $(docker ps -as | grep "$id" | awk '{print $1}') != "$id" ]]; then
        log.error "Docker ID not match!"
        log.sub "Reference ID -> $id"
        exit 1
    fi
    startanimation "Shutdown $name"
    docker stop $id &>/dev/null && (stopanimation "done") || { stopanimation "error" && exit 1; }
fi
startanimation "Remove $name"
rm core/modules/confs/$modulename.conf || { stopanimation "error" && log.error "Conf can not removed!" && log.sub "PATH -> /opt/PHT/core/modules/confs/$modulename.conf" && exit 1; }
rm -r core/modules/$modulename || { stopanimation "error" && log.error "Module Path can not removed!" && log.sub "PATH -> /opt/PHT/core/modules/$modulename" && exit 1; }
docker remove $id &>/dev/null || { stopanimation "error" && log.error "Container can not removed!" && log.sub "Reference ID -> $id" && exit 1; }
stopanimation "done"
log.info "Module $name removed."
exit 0
