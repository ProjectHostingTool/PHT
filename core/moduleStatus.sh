modulename="$2"
mpath="/opt/PHT/core/modules"
! [[ -f "core/modules/confs/$modulename.conf" ]] && log.error "Module conf not found!" && log.sub "/opt/PHT/core/modules/confs/$modulename.conf" && exit 1

confindex "core/modules/confs/$modulename.conf"

(! [[ -d "$mpath/$name" ]] && log.error "Module Path not found" && log.sub "Path: $mpath/$name") || log.info "Name -> $name"
([[ $(docker ps -as | grep "$name") =~ ("up"|"UP"|"Up") ]] && log.info "Status -> ${GREEN}UP") || log.info "Status -> ${RED}DOWN"
(! [[ -f "$mpath/$name/$exec" ]] && log.error "Module Exec not found" && log.sub "Path: $mpath/$name/$exec") || log.info "Exec -> $exec"
(! [[ $(docker ps -as | grep "$name" | awk '{print $1}') == "$id" ]] && log.error "Module Container ID incorrect" && log.sub "ID: $id") || log.info "ID   -> $id"
variables=("path" "ip" "port" "vpath")
for var in "${variables[@]}"; do
    if [ -z "${!var}" ]; then
        log.warn "$var -> empty or not defined"
    else
        log.info "$var -> ${!var}"
    fi
done