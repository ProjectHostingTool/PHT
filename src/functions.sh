GitNetworkControl() {
    if ping -c 1 github.com > /dev/null; then
        return 0
    else
        return 1
    fi
}

confindex() {
    [[ -z $1 ]] && log.error "You have set the file path as argument" && return 1
    ! [[ -f "$1" ]] && log.error "File not found" && log.submessage "PATH -> $1" && return 1
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
            *) log.warn "Unknown key found: $key" && continue ;;
        esac
    done < "$1"
}

isCommandExist() {
    local command="$1"
    if command -v "${command%% *}" &> /dev/null || [[ $command =~ ('&&'|'||'|';'|'|') ]]; then
            log.info "Catch: $command"
            return 0
        fi
    return 1
}

runupdate() {
    (GitNetworkControl && { source core/updater.sh || log.error "Update failed!"; }) || { log.warn "Github connection unavailable." && log.submessage "System update process skipped."; }
}
caseelse() {
    log.error "You must set the parameter!"
    log.setline
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
        echo -ne "\r${WHITE}[${GREEN}SUCCESS${WHITE}] ${BLUE}${message}${RESET_COLOR}\n"
        echo -e "stopped" > /tmp/phtanimation.status
        return 0
    elif [[ $value =~ ("error"|"fail") ]]; then
        echo -ne "\r${WHITE}[${RED}${BLINK}FAIL${STOPBLINK}${WHITE}]  ${BLUE}${message}${RESET_COLOR}\n"
        echo -e "stopped" > /tmp/phtanimation.status
        return 1
    elif [[ $value == "warn" ]]; then
        echo -ne "\r${WHITE}[${YELLOW}WARN${WHITE}]    ${BLUE}${message}${RESET_COLOR}\n"
        echo -e "stopped" > /tmp/phtanimation.status
        return 0
    else
        echo -ne "\r${WHITE}[${RED}${BLINK}FAIL${STOPBLINK}${WHITE}]  ${BLUE}UNKNOWN PARAMETER(${value})${RESET_COLOR}\n"
        echo -e "stopped" > /tmp/phtanimation.status
    fi
}

startanimation() {
    ! [[ -f /tmp/phtanimation.status ]] && touch /tmp/phtanimation.status;
    [[ "$(cat /tmp/phtanimation.status | head -n1)" == 'true' ]] && log.error "Animation already active!" && return 1
    [[ "$(cat /tmp/phtanimation.status | head -n1)" =~ ("done"|"success"|"error"|"fail"|"warn") ]] && log.error "Status file not RESET_COLORed, you must check the codes!" && return 1
    [[ -z $1 ]] && log.error "You have to set process name!" && return 1
    echo -e "true" > /tmp/phtanimation.status
    animation "$1" &
    return 0
}

stopanimation() {
    [[ "$(cat /tmp/phtanimation.status | head -n1)" =~ 'stopped' ]] && log.error "Animation already stopped!" && return 1
    ! [[ "$(cat /tmp/phtanimation.status | head -n1)" =~ 'true' ]] && log.error "Animation not running!" && return 1
    local status="$1"

    if ! [[ $status =~ ("done"|"success"|"error"|"warn"|"fail") ]]; then
        log.error "You have to set status!"
        log.submessage "Usage: stopanimation <done/fail/warn>"
        return 1
    fi
    echo -e "$status" > /tmp/phtanimation.status
    while ! [[ "$(cat /tmp/phtanimation.status | head -n1)" =~ 'stopped' ]]; do
        sleep 0.2
    done
    return 0
}
