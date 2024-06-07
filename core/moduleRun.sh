modulename="$2"
params=("$@")
! [[ -f "core/modules/confs/$modulename.conf" ]] && errorlog "Module conf not found!" && sublog "/opt/PHT/core/modules/confs/$modulename.conf" && exit 1

confindex "core/modules/confs/$modulename.conf"

if [[ "$3" =~ ("-t"|"--terminal"|"terminal"|"-c"|"--console"|"console") ]];then 
    [[ -z "${params[@]:3}" ]] && warnlog "You must set arguments." && sublog "Ex: bash, cat <args>" && exit 1
    if [[ $(docker ps -as | grep "$id") =~ ("up"|"UP"|"Up") ]]; then
        infolog "System already running. Connecting..."
        docker exec -it $id ${params[@]:3}
    else 
        docker start $id && docker exec -it $id ${params[@]:3}
        startanimation "Stopping..."
        docker stop $id &>/dev/null &
        [[ "$?" == "0" ]] && { stopanimation "done" && exit 0; } || { stopanimation "error" && exit 1; }
    fi
    exit 0
fi

! [[ -d "core/modules/$modulename" ]] && errorlog "Module path not found!"      && sublog "/opt/PHT/core/modules/$modulename" && exit 1
! [[ -f "core/modules/$name/$exec" ]] && errorlog "Module exec file not found!" && sublog "/opt/PHT/core/modules/$modulename/$exec" && exit 1

[[ $(docker ps -as | grep "$id" | awk '{print $1}') != "$id" ]] && errorlog "Docker ID not match!"   && sublog "Reference ID -> $id" && exit 1
[[ $(docker ps -as | grep "$id") =~ ("up"|"UP"|"Up") ]]         && infolog "System already running." && exit 0

docker start $id 1> /tmp/phtrun.error || { errorlog "Something went wrong during starting $id!" && exit 1; }
docker exec -it $id bash -c "cd $vpath && bash $vpath/$exec" ${params[@]:2} || { errorlog "Something went wrong during running $id!" && exit 1; }

sleep 2

if [[ $(docker ps -as | grep "$name") =~ ("up"|"UP"|"Up") ]]; then
    startanimation "Shutdown"
    docker stop $id &>/dev/null && { stopanimation "done" && exit 0; } || { stopanimation "error" && exit 1; }
else
    infolog "Stopped by second or third part."
    exit 0
fi