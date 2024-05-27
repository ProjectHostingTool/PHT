#!/bin/bash

conf_file="$2"
[[ ! -f "$conf_file" ]] && errorlog "File not found!" && sublog "path: $conf_file" && exit 1
[[ ! "$conf_file" =~ ".pht" ]] && warnlog "Error file format." && sublog "you must use .pht format." && exit 1

while IFS='=' read -r key value
do
    if [[ -z "${key}" || ${key:0:1} == "#" ]]; then
        continue
    fi

    case "$key" in
        "os") os="$value" ;;
        "giturl") giturl="$value" ;;
        "exec") exec="$value" ;;
        "vpath") vpath="$value" ;;
        *) warnlog "Unknown key found: $key" ;;
        echo -e "$value"
    esac
done < "$conf_file"

# Define the list of variables to check
variables=("os" "giturl" "exec" "vpath")
for var in "${variables[@]}"; do
    if [ -z "${!var}" ]; then
        errorlog "Error: $var is empty or not defined" && exit 1
    fi
done

! [[ "$giturl" =~ ".git" ]] && giturl="$giturl.git"
name="$(basename -s .git $giturl)"

[[ -d "/opt/PHT/core/modules/$name" ]] && errorlog "Same named module already exist." && exit 1

[[ "${vpath: -1}" == "/" ]] && vpath="${vpath%?}"
[[ "${vpath:0:1}" != "/" ]] && vpath="/$vpath"

infolog "Name           : $name"
infolog "OS             : $os"
infolog "Git URL        : $giturl"
infolog "Exec Script    : $exec"
infolog "VPath          : $vpath"

setline

# Check the connection
startanimation "Checking Connection" 
response=$(curl -I -s -o /dev/null -w "%{http_code}" "$giturl")
if [ "$response" -ne 301 ]; then
    stopanimation "error"
    sublog "Cloning is not possible!, HTTP status code: $response"
    exit 1
else
    stopanimation "done"
    sublog "HTTP status code: $response"
fi

# Git cloning
startanimation "Cloning $name"
git clone "$giturl" "core/modules/$name" &>/dev/null
if ! [[ -d "core/modules/$name/" ]]; then
    stopanimation "error"
    sublog "Path not found: $(pwd)/core/modules/$name"
    exit 1
else
    if [[ -f "core/modules/$name/$exec" ]]; then
        stopanimation "done"
        sublog "Run File setted -> $(pwd)/core/modules/$name/$exec"
    else
        stopanimation "error"
        sublog "Startup file not found: $(pwd)/core/modules/$name/$exec"
        rm -r "$(pwd)/core/modules/$name/"
        exit 1
    fi
fi

# Install img
startanimation "Setup Container" 
if ! (docker images --format '{{.Repository}}' | grep -q "^$os$"); then
    docker pull $os 1>/dev/null 2>/tmp/phtdocker.log
    [[ "$?" != 0 ]] && stopanimation "error" && sublog "$(cat /tmp/phtdocker.log)" && rm -r "$(pwd)/core/modules/$name/" && exit 1
fi

num="$((laststaticip=$(<core/modules/staticIp.list)+1))"

if [[ $num -gt 255 ]]; then
  num=$((num - 255))
  containerip="172.20.$num.255"
else
  containerip="172.20.0.$num"
fi

while true; do
  PORT=$(shuf -i 1024-49151 -n 1)
  if ! sudo netstat -tuln | grep -q ":$PORT "; then
    AVAILABLE_PORT=$PORT
    break
  fi
done

echo "$num" > core/modules/staticIp.list

# Create Container
docker run -d --name "$name" --net phtnetwork -e DISPLAY=$DISPLAY -e --volume="$XDG_RUNTIME_DIR/pulse/native:/tmp/pulse.socket" -v /run/user/1000/pulse:/run/user/1000/pulse -v /tmp/.X11-unix:/tmp/.X11-unix:rw --device /dev/dri:/dev/dri --privileged=true --device=/dev/snd:/dev/snd -p ${AVAILABLE_PORT}:80 --ip "$containerip" -v "/opt/PHT/core/modules/$name":"$vpath" $os tail -f /dev/null > /tmp/phtdocker.log 2>&1
[[ "$?" != 0 ]] && stopanimation "error" && sublog "$(cat /tmp/phtdocker.log)" && rm -r "$(pwd)/core/modules/$name/" && exit 1

# Set the conf file
containerid="$(docker ps -as | grep "$name" | awk '{print $1}')"
echo -e "name=$name\nip=$containerip\nid=$containerid\nport=${AVAILABLE_PORT}:80\npath=/opt/PHT/core/modules/$name\nvpath=$vpath\nexec=$exec\ngiturl=$giturl" > "core/modules/confs/$name.conf"
stopanimation "done"
sublog "Module name        -> $name"
sublog "Static .conf file  -> /opt/PHT/core/modules/confs/$name.conf"
sublog "Vpath              -> $vpath"
sublog "Module Id          -> $containerid"
sublog "Module IP          -> $containerip"
sublog "Module PORT        -> ${AVAILABLE_PORT}:80"
sublog "Run Command        -> pht run $name"
startanimation "Finishing..."
docker stop $containerid
stopanimation "done"