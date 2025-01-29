modulename="$2"
! [[ -f "core/modules/confs/$modulename.conf" ]] && log.error "Module conf not found!" && log.sub "/opt/PHT/core/modules/confs/$modulename.conf" && exit 1

confindex "core/modules/confs/$modulename.conf"

if [[ $(docker ps -as | grep "$name") =~ ("Exited"|"exited") ]]; then
    log.warn "System already exited."
    exit 1
else
    if [[ $(docker ps -as | grep "$id" | awk '{print $1}') != "$id" ]]; then
        log.error "Docker ID not match!"
        log.sub "Reference ID -> $id"
        exit 1
    fi
    startanimation "Shutdown $name"
    docker stop $id &>/dev/null && (stopanimation "done" && exit 0) || (stopanimation "error" && exit 1)
fi