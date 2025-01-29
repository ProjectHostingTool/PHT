#!/bin/bash

if ! [[ $(whoami) == "root" ]]; then
    echo "Please run this script with sudo or as root."
    exit 1
fi

if ! ping -c 1 github.com > /dev/null; then
    echo -e "You must have an internet connection!" && exit 1
fi


# Colors
    RESET_COLOR="\e[0m"
    RED="\e[0;31m"
    GREEN="\e[0;32m"
    YELLOW="\e[0;33m"
    CYAN="\e[0;36m"
    BLINK="\e[5m"
    BLUE="\e[0;34m"
    MAGENTA="\e[0;35m"
    STOPBLINK="\033[0m"

# Log Levels
    function log() {
        local level="$1"
        local color="$2"
        local message="$3"

        echo -e "${RESET_COLOR} [${color}$level${RESET_COLOR}]${color}>${RESET_COLOR} $message"
    }

    function log.sub() {
        echo -e "\t${MAGENTA}o ${RESET_COLOR}$1" && sleep 0.2
    }
    function log.info() {
        log "INFO" "$BLUE" "$1"
    }

    function log.warn() {
        log "WARN" "$YELLOW" "$1"
    }

    function log.error() {
        log "ERROR" "$RED" "$1"
    }

    function log.done() {
        log "DONE" "$GREEN" "$1"
    }

# Banner
    echo ""
    echo -e "███████████  █████   █████ ███████████" 
    echo -e "░░███░░░░░███░░███   ░░███ ░█░░░███░░░█" 
    echo -e " ░███    ░███ ░███    ░███ ░   ░███  ░ " 
    echo -e " ░██████████  ░███████████     ░███" 
    echo -e " ░███░░░░░░   ░███░░░░░███     ░███" 
    echo -e " ░███         ░███    ░███     ░███" 
    echo -e " █████        █████   █████    █████" 
    echo -e "░░░░░        ░░░░░   ░░░░░    ░░░░░    ${GREEN}version : ${MAGENTA}1.0${RESET_COLOR}
    "


# Install Depends
    if [[ $(command -v pacman) ]]; then
        log.info "Installing docker git and less"
        (pacman -S docker git less curl --noconfirm &> /tmp/phtsetup.log && log.done "Installation done") || (log.error "Installation faild" && cat /tmp/phtsetup.log | less && exit 1)
    elif [[ $(command -v apt) ]]; then
        log.info "Installing docker git and less"
        (apt update && apt install docker.io git less curl -yq &> /tmp/phtsetup.log && log.done "Installation done") || (log.error "Installation faild" && cat /tmp/phtsetup.log | less && exit 1)
    else
        log.warn "Please Install docker, git and less first" && exit 1
    fi

# Move /opt/PHT to /opt/PHT.old if it exists
    if [ -d /opt/PHT ]; then
        [[ -d /opt/PHT.old ]] && rm -r /opt/PHT.old
        mv /opt/PHT /opt/PHT.old
        log.info "Moving /opt/PHT to /opt/PHT.old"
    fi

# Clone and Check
    git clone https://github.com/ProjectHostingTool/PHT.git /opt/PHT > /dev/null 2>&1 || (log.error "System cloning process went wrong." && log.sub "git clone https://github.com/ProjectHostingTool/PHT.git" && exit 1)

# Setup Docker Network and Xhost
    ! [[ $(docker network ls | grep phtnetwork) =~ "phtnetwork" ]] && (docker network create --subnet=172.20.0.0/16 --gateway=172.20.0.1 phtnetwork 1>/dev/null || (log.error "Docker network setup fail!" && exit 1))
    which xhost &> /dev/null && xhost +local:docker

# Finalize
    echo -e 'sudo bash /opt/PHT/main.sh $@' > /bin/pht
    chmod +x /bin/pht
    mkdir /opt/PHT/core/modules/confs &> /dev/null

    [[ -f setup.sh ]] && rm setup.sh

    cd /opt/PHT
    git rm -r --cached core/modules/

    log.done "System setted up."
    exit 0 