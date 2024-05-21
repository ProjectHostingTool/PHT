#!/bin/bash
mpath="/opt/PHT/core/modules"
conflist=("$mpath"/confs/*.conf)
[[ -z "$(ls -A $mpath/confs/)" ]] && infolog "There is no module" && exit 1

for file in "${conflist[@]}"; do
    confindex "$file"
    setline
    (! [[ -d "$mpath/$name" ]] && errorlog "Module Path not found" && sublog "Path: $mpath/$name") || infolog "Name -> $name"
    ([[ $(docker ps -as | grep "${name}") =~ ("up"|"UP"|"Up") ]] && infolog "Status -> ${GREEN}UP") || infolog "Status -> ${RED}DOWN"
    (! [[ -f "$mpath/$name/$exec" ]] && errorlog "Module Exec not found" && sublog "Path: $mpath/$name/$exec") || infolog "Exec -> $exec"
    (! [[ $(docker ps -as | grep "$name" | awk '{print $1}') == "$id" ]] && errorlog "Module Container ID incorrect" && sublog "ID: $id") || infolog "ID   -> $id"
    variables=("path" "ip" "port" "vpath")
    for var in "${variables[@]}"; do
        if [ -z "${!var}" ]; then
            warnlog "$var -> empty or not defined"
        else
            infolog "$var -> ${!var}"
        fi
    done    
done
