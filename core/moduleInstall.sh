#!/bin/bash

conf_file="$2"
if ! [[ "${conf_file:0:1}" == "/" ]]; then
    conf_file="$callerwd/$conf_file"
fi

[[ ! -f "$conf_file" ]] && log.error "File not found!" && log.sub "path: $conf_file" && exit 1
[[ ! "$conf_file" =~ ".pht" ]] && log.warn "Error file format." && log.sub "you must use .pht format." && exit 1

function commandCheck() {
    isCommandExist "$value" && log.warn "You can not set any system command(s) in vars values!" && exit 1 || return 0
}

while IFS='=' read -r key value || [[ -n "$key" ]]; do
    [[ -z "${key}" || ${key:0:1} == "#" ]] && continue
    case "$key" in
        "os")     commandCheck && os="$value"     ;;
        "exec")   commandCheck && exec="$value"   ;;
        "vpath")  commandCheck && vpath="$value"  ;;
        "giturl") commandCheck && giturl="$value" ;;
        *) log.warn "Unknown key found: $key"     ;;
    esac
done < "$conf_file"

# Define the list of variables to check
variables=("os" "giturl" "exec" "vpath")
for var in "${variables[@]}"; do
    if [ -z "${!var}" ]; then
        log.error "Error: $var is empty or not defined" && exit 1
    fi
done

! [[ "$giturl" =~ ".git" ]] && giturl="$giturl.git"
name="$(basename -s .git $giturl)"

[[ -d "/opt/PHT/core/modules/$name" ]] && log.error "Same named module already exist." && exit 1

[[ "${vpath: -1}" == "/" ]] && vpath="${vpath%?}"
[[ "${vpath:0:1}" != "/" ]] && vpath="/$vpath"

log.info "Name           : $name"
log.info "OS             : $os"
log.info "Git URL        : $giturl"
log.info "Exec Script    : $exec"
log.info "VPath          : $vpath"

log.setline

# Check the connection
startanimation "Checking Connection" 
response=$(curl -I -s -o /dev/null -w "%{http_code}" "$giturl")
if [ "$response" -ne 301 ]; then
    stopanimation "error"
    log.sub "Cloning is not possible!, HTTP status code: $response"
    exit 1
else
    stopanimation "done"
    log.sub "HTTP status code: $response"
fi

# Git cloning
startanimation "Cloning $name"
git clone "$giturl" "core/modules/$name" &>/dev/null
if ! [[ -d "core/modules/$name/" ]]; then
    stopanimation "error"
    log.sub "Path not found: $(pwd)/core/modules/$name"
    exit 1
else
    if [[ -f "core/modules/$name/$exec" ]]; then
        stopanimation "done"
        log.sub "Run File setted -> $(pwd)/core/modules/$name/$exec"
    else
        stopanimation "error"
        log.sub "Startup file not found: $(pwd)/core/modules/$name/$exec"
        rm -r "$(pwd)/core/modules/$name/"
        exit 1
    fi
fi

# Install img
startanimation "Setup Container" 
if ! (docker images --format '{{.Repository}}' | grep -q "^$os$"); then
    docker pull $os 1>/dev/null 2>/tmp/phtdocker.log
    [[ "$?" != 0 ]] && stopanimation "error" && log.sub "$(cat /tmp/phtdocker.log)" && rm -r "$(pwd)/core/modules/$name/" && exit 1
fi

laststaticip=$(<core/modules/staticIp.list)

segment1="${laststaticip%%.*}"
remaining="${laststaticip#*.}"
segment2="${remaining%%.*}"
remaining="${remaining#*.}"
segment3="${remaining%%.*}"
segment4="${remaining#*.}"

if [[ $segment4 -eq 255 ]]; then
    if [[ $segment3 -eq 255 ]]; then
        containerip="172.$((segment2 + 1)).1.1"
    else
        containerip="172.$segment2.$((segment3 + 1)).1"
    fi
else
  containerip="172.$segment2.$segment3.$((segment4 + 1))"
fi

while true; do
  PORT=$(shuf -i 1024-49151 -n 1)
  if ! sudo netstat -tuln | grep -q ":$PORT "; then
    AVAILABLE_PORT=$PORT
    break
  fi
done

echo "$containerip" > core/modules/staticIp.list

# Create Container
# Check if Wayland is available
if [ -n "$WAYLAND_DISPLAY" ]; then
    wayland_flags="-e WAYLAND_DISPLAY=$WAYLAND_DISPLAY -v $XDG_RUNTIME_DIR/wayland:/tmp/wayland"
else
    wayland_flags=""
fi

# Now run the docker container
docker run -d \
  --name "$name" \
  --net phtnetwork \
  -e DISPLAY=$DISPLAY \
  $wayland_flags \
  -v "$XDG_RUNTIME_DIR/pulse/native:/tmp/pulse.socket" \
  -v /run/user/1000/pulse:/run/user/1000/pulse \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  --device /dev/dri:/dev/dri \
  --privileged=true \
  --device=/dev/snd:/dev/snd \
  -p ${AVAILABLE_PORT}:80 \
  --ip "$containerip" \
  -v "/opt/PHT/core/modules/$name":"$vpath" \
  $os tail -f /dev/null > /tmp/phtdocker.log 2>&1


[[ "$?" != 0 ]] && stopanimation "error" && log.sub "$(cat /tmp/phtdocker.log)" && rm -r "$(pwd)/core/modules/$name/" && exit 1

# Set the conf file
containerid="$(docker ps -as | grep "$name" | awk '{print $1}')"
echo -e "name=$name\nip=$containerip\nid=$containerid\nport=${AVAILABLE_PORT}:80\npath=/opt/PHT/core/modules/$name\nvpath=$vpath\nexec=$exec\ngiturl=$giturl" > "core/modules/confs/$name.conf"
stopanimation "done"
log.sub "Module name        -> $name"
log.sub "Static .conf file  -> /opt/PHT/core/modules/confs/$name.conf"
log.sub "Vpath              -> $vpath"
log.sub "Module Id          -> $containerid"
log.sub "Module IP          -> $containerip"
log.sub "Module PORT        -> ${AVAILABLE_PORT}:80"
log.sub "Run Command        -> pht run $name"
startanimation "Finishing..."
docker stop $containerid
chmod -R 777 /opt/PHT/core/modules/$name
stopanimation "done"
