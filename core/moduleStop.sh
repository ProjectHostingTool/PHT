modulename="$2"
! [[ -f "core/modules/confs/$modulename.conf" ]] && errorlog "Module conf not found!" && sublog "/opt/PHT/core/modules/confs/$modulename.conf" && exit 1

confindex "core/modules/confs/$modulename.conf"

if [[ $(docker ps -as | grep "$name") =~ ("Exited"|"exited") ]]; then
    warnlog "System already exited."
    exit 1
else
    if [[ $(docker ps -as | grep "$id" | awk '{print $1}') != "$id" ]]; then
        errorlog "Docker ID not match!"
        sublog "Reference ID -> $id"
        exit 1
    fi
    startanimation "Shutdown $name"
    docker stop $id &>/dev/null && (stopanimation "done" && exit 0) || (stopanimation "error" && exit 1)
fi