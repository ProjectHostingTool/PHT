modulename="$2"
shift 2
params=("$@")

! [[ -f "core/modules/confs/$modulename.conf" ]] && log.error "Module conf not found!" && log.submessage "/opt/PHT/core/modules/confs/$modulename.conf" && exit 1

confindex "core/modules/confs/$modulename.conf"

# Check the connection
startanimation "Checking Connection" 
response=$(curl -I -s -o /dev/null -w "%{http_code}" "$giturl")
if [ "$response" -ne 301 ]; then
    stopanimation "error"
    log.submessage "Update is not possible!, HTTP status code: $response"
    exit 1
else
    stopanimation "done"
    log.submessage "HTTP status code: $response"
fi

# Git cloning
startanimation "Updating $name"
[[ -z $params ]] && params="origin main"
git -C /opt/PHT/core/modules/$name reset --hard 1> /dev/null 2> "/tmp/$name-update.log" && git -C /opt/PHT/core/modules/$name pull $params 1> /dev/null 2> "/tmp/$name-update.log"
if [[ $? == 0 ]]; then
    stopanimation "done"
    log.submessage "$name is Up to date"
else
    stopanimation "error"
    log.submessage "Update done but startup file not found: $(pwd)/core/modules/$name/$exec"
    echo -ne "Do you want to view process log? (y/N)"
    read -e updatelogchoie
    [[ $updatelogchoie =~ ^(y|Y) ]] && cat "/tmp/$name-update.log" | less
    exit 1
fi