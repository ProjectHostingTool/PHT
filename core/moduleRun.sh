params=("$@")
modulename="$2"
[[ -z $modulename ]] && log.error "You have to set module name!" && exit 1
! [[ -f "core/modules/confs/$modulename.conf" ]] && log.error "Module conf not found!" && log.sub "/opt/PHT/core/modules/confs/$modulename.conf" && exit 1
! [[ -d "core/modules/$modulename" ]] && log.error "Module path not found!"      && log.sub "/opt/PHT/core/modules/$modulename" && exit 1

confindex "core/modules/confs/$modulename.conf"
[[ $(docker ps -as | grep "$id" | awk '{print $1}') != "$id" ]] && log.error "Docker ID not match!"   && log.sub "Reference ID -> $id" && exit 1

if [[ "$3" =~ ("-t"|"--terminal"|"terminal"|"-c"|"--console"|"console") ]];then 
    [[ -z "${params[@]:3}" ]] && log.warn "You must set arguments." && log.sub "Ex: bash, cat <args>" && exit 1
    if [[ $(docker ps -as | grep "$id") =~ ("up"|"UP"|"Up") ]]; then
        log.info "System already running. Connecting..."
        docker exec -it $id ${params[@]:3}
    else 
        docker start $id && docker exec -it $id ${params[@]:3}
        startanimation "Stopping..."
        docker stop $id &>/dev/null &
        [[ "$?" == "0" ]] && { stopanimation "done" && exit 0; } || { stopanimation "error" && exit 1; }
    fi
    exit 0
fi

! [[ -f "core/modules/$name/$exec" ]] && log.error "Module exec file not found!" && log.sub "/opt/PHT/core/modules/$modulename/$exec" && exit 1
[[ $(docker ps -as | grep "$id") =~ ("up"|"UP"|"Up") ]] && log.info "System already running."  && log.sub "if you want to connect use '--console' parameter." && exit 0

docker start $id 1> /tmp/phtrun.error || { log.error "Something went wrong during starting $id!" && exit 1; }
cutparam=${params[@]:2}
docker exec -it $id bash -c "cd $vpath && bash $exec $cutparam"  # || { log.error "Something went wrong during running $id!" && exit 1; }

sleep 2

if [[ $(docker ps -as | grep "$name") =~ ("up"|"UP"|"Up") ]]; then
    startanimation "Shutdown"
    docker stop $id &>/dev/null && { stopanimation "done" && exit 0; } || { stopanimation "error" && exit 1; }
else
    log.info "Stopped by second or third part."
    exit 0
fi