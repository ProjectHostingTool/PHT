#!/bin/bash

if ! [ "$UID" -eq 0 ]; then
    echo "You are not running as root. Please run this script with sudo or as root."
    exit 1
fi

if ! command -v dpkg >/dev/null && ! command -v apt-get >/dev/null; then
    echo "Distribution is not based on Debian." && exit 1
fi

if ! ping -c 1 github.com > /dev/null; then
    echo -e "You must have an internet connection!" && exit 1
fi


# Functions
errorlog() {
    echo -e "${RESEST}[${RED}${BLINK}ERROR${STOPBLINK}${RESEST}] $1" && sleep 0.2
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

# Update package lists
apt update &> /dev/null

! [[ -f /usr/bin/curl ]] && apt install curl -yq &> /dev/null

curl https://raw.githubusercontent.com/ProjectHostingTool/PHT/main/src/colors.sh -s -o /tmp/colors.sh
if [[ $(cat "/tmp/colors.sh" | head -n1) =~ "# Define color variables" ]]; then
    source "/tmp/colors.sh"
else
    errorlog "Colors not imported, you have to check github.com connection."
fi

curl https://raw.githubusercontent.com/ProjectHostingTool/PHT/main/src/banners.sh -s -o /tmp/banners.sh
if [[ $(cat "/tmp/banners.sh" | head -n1) =~ "# PHT banner" ]]; then
    source "/tmp/banners.sh"
else
    errorlog "Banners not imported, you have to check github.com connection."
fi


banner1 2> /dev/null

# Install Docker if not already installed
if ! command -v docker >/dev/null; then
    infolog "Installing docker.io"
    apt install docker.io -yq &> /dev/null
    if ! command -v docker >/dev/null; then
        errorlog "Installation failed, try manually."
        exit 1
    else
        successlog "Docker Installed."
    fi
else
    infolog "Docker found."
fi

# Install Git if not already installed
if ! command -v git >/dev/null; then
    infolog "Installing git"
    apt install git -yq &> /dev/null
    if ! command -v git >/dev/null; then
        errorlog "Installation failed, try manually."
        exit 1
    else
        successlog "Git installed."
    fi
else
    infolog "Git found."
fi


# Install xpra if not already installed
if ! command -v xpra >/dev/null; then
    infolog "Installing git"
    apt install xpra -yq &> /dev/null
    if ! command -v xpra >/dev/null; then
        errorlog "Installation failed, try manually."
        exit 1
    else
        successlog "xpra installed."
    fi
else
    infolog "xpra found."
fi


# Move /opt/PHT to /opt/PHT.old if it exists
if [ -d /opt/PHT ]; then
    [[ -d /opt/PHT.old ]] && rm -r /opt/PHT.old
    mv /opt/PHT /opt/PHT.old
    infolog "Moving /opt/PHT to /opt/PHT.old"
fi

cd /opt/
git clone https://github.com/ProjectHostingTool/PHT.git > /dev/null 2>&1

# Check if the clone was successful
if [ ! -d /opt/PHT ]; then
    errorlog "System cloning process went wrong. \ncode: git clone https://github.com/ProjectHostingTool/PHT.git"
    exit 1
fi

! [[ $(docker network ls | grep phtnetwork) =~ "phtnetwork" ]] && (docker network create --subnet=172.20.0.0/16 --gateway=172.20.0.1 phtnetwork 1>/dev/null || (errorlog "Docker network setup fail!" && exit 1))

xhost +local:docker

ln -sf /opt/PHT/main.sh /bin/pht
mkdir /opt/PHT/core/modules/confs &> /dev/null
chmod +x /bin/pht

[[ -f setup.sh ]] && rm setup.sh
rm /tmp/colors.sh

cd PHT/
git rm --cached core/modules/staticIp.list
git rm --cached core/logs/updater.log

successlog "System files installed."
exit 0