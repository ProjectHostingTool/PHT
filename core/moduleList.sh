#!/bin/bash
mpath="/opt/PHT/core/modules"
conflist=("$mpath"/confs/*.conf)
[[ -z "$(ls -A $mpath/confs/)" ]] && log.info "There is no module" && exit 1

for file in "${conflist[@]}"; do
    confindex "$file"
    log.setline
    (! [[ -d "$mpath/$name" ]] && log.error "Module Path not found" && log.sub "Path: $mpath/$name") || log.info "Name -> $name"
    ([[ $(docker ps -as | grep "${name}") =~ ("up"|"UP"|"Up") ]] && log.info "Status -> ${GREEN}UP") || log.info "Status -> ${RED}DOWN"
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
done
