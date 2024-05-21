modulename="$2"
mpath="/opt/PHT/core/modules"
! [[ -f "core/modules/confs/$modulename.conf" ]] && errorlog "Module conf not found!" && sublog "/opt/PHT/core/modules/confs/$modulename.conf" && exit 1

confindex "core/modules/confs/$modulename.conf"

(! [[ -d "$mpath/$name" ]] && errorlog "Module Path not found" && sublog "Path: $mpath/$name") || infolog "Name -> $name"
([[ $(docker ps -as | grep "$name") =~ ("up"|"UP"|"Up") ]] && infolog "Status -> ${GREEN}UP") || infolog "Status -> ${RED}DOWN"
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