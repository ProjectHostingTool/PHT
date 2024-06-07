errorlog() {
    echo -e "${RESET}[${RED}${BLINK}ERROR${STOPBLINK}${RESET}] $1" && sleep 0.2
}
warnlog() {
    echo -e "${RESET}[${YELLOW}WARN${RESET}] $1" && sleep 0.2
}
successlog() {
    echo -e "${RESET}[${GREEN}SUCCESS${RESET}] $1" && sleep 0.2
}
infolog() {
    echo -e "${RESET}[${CYAN}INFO${RESET}] $1" && sleep 0.2
}
sublog() {
    echo -e "\t${RESET}${MAGENTA}ㄷ ${WHITE}$1" && sleep 0.2
}
GitNetworkControl() {
    if ping -c 1 github.com > /dev/null; then
        return 0
    else
        return 1
    fi
}
setline() {
    # Get the size of the terminal
    local columns=$(tput cols)
    local total=""
    for ((i=1; i<=$columns; i++)); do
        total+="-"
    done
    echo -e "$1$total"
}
confindex() {
    [[ -z $1 ]] && errorlog "You have set the file path as argument" && return 1
    ! [[ -f "$1" ]] && errorlog "File not found" && sublog "PATH -> $1" && return 1
    while IFS='=' read -r key value; do
        # Skip empty lines and comments
        [[ -z $key || ${key:0:1} == "#" ]] && continue

        case "$key" in
            "name") name="$value" ;;
            "path") path="$value" ;;
            "ip") ip="$value" ;;
            "id") id="$value" ;;
            "port") port="$value" ;;
            "exec") exec="$value" ;;
            "vpath") vpath="$value" ;;
            "giturl") giturl="$value" ;;
            *) warnlog "Unknown key found: $key" && continue ;;
        esac
    done < "$1"
}

isCommandExist() {
    local command="$1"
    if command -v "${command%% *}" &> /dev/null || [[ $command =~ ('&&'|'||'|';'|'|') ]]; then
            infolog "Catch: $command"
            return 0
        fi
    return 1
}

runupdate() {
    {GitNetworkControl && { source core/updater.sh || errorlog "Update failed!"; }} ||  { warnlog "Github connection unavailable." && sublog "System update process skipped."; }
}
caseelse() {
    errorlog "You must set the parameter!"
    setline
    pht help commands
}
animation(){
    local spinner=('|' '/' '—' '\\')
    local message="$1"
    local value=""
    while [[ $(cat /tmp/phtanimation.status | head -n1) =~ "true" ]]; do
        for i in ${spinner[@]}; do
            echo -ne "\r${WHITE}[${CYAN}${i}${WHITE}] ${message}"
            sleep 0.2
        done
    done

    value="$(cat /tmp/phtanimation.status | head -n1)"

    if [[ $value =~ ("done"|"success") ]]; then
        echo -ne "\r${WHITE}[${GREEN}SUCCESS${WHITE}] ${BLUE}${message}${RESET}\n"
        echo -e "stopped" > /tmp/phtanimation.status
        return 0
    elif [[ $value =~ ("error"|"fail") ]]; then
        echo -ne "\r${WHITE}[${RED}${BLINK}FAIL${STOPBLINK}${WHITE}]  ${BLUE}${message}${RESET}\n"
        echo -e "stopped" > /tmp/phtanimation.status
        return 1
    elif [[ $value == "warn" ]]; then
        echo -ne "\r${WHITE}[${YELLOW}WARN${WHITE}]    ${BLUE}${message}${RESET}\n"
        echo -e "stopped" > /tmp/phtanimation.status
        return 0
    fi
}
startanimation() {
    ! [[ "$(cat /tmp/phtanimation.status | head -n1)" =~ ('stopped'|''|"done"|"success"|"error"|"warn") ]] && errorlog "Animation already active!" && exit 1
    [[ "$(cat /tmp/phtanimation.status | head -n1)" =~ ("done"|"success"|"error"|"warn") ]] && errorlog "Status file not reseted, you must check the codes!" && return 1
    [[ -z $1 ]] && errorlog "You have to set process name!" && return 1
    echo -e "true" > /tmp/phtanimation.status
    animation "$1" &
    return 0
}
stopanimation() {
    [[ "$(cat /tmp/phtanimation.status | head -n1)" =~ 'stopped' ]] && errorlog "Animation already stopped!" && return 1
    local status="$1"

    if ! [[ $status =~ ("done"|"success"|"error"|"warn"|"fail") ]]; then
        errorlog "You have to set status!"
        sublog "Usage: stopanimation <done/fail/warn>"
        return 1
    fi
    echo -e "$status" > /tmp/phtanimation.status
    while ! [[ "$(cat /tmp/phtanimation.status | head -n1)" =~ 'stopped' ]]; do
        sleep 0.2
    done
    return 0
}
