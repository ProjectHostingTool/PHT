#!/bin/bash

if ! [ "$UID" -eq 0 ]; then
    echo "You are not running as root. Please run this script with sudo or as root."
    exit 1
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

# Function to determine the package manager and install a package
install_package() {
    local package=$1
    if command -v apt >/dev/null; then
        apt install -yq "$package" &> /dev/null
    elif command -v pacman >/dev/null; then
        pacman -S --noconfirm "$package" &> /dev/null
    elif command -v yum >/dev/null; then
        yum install -y "$package" &> /dev/null
    elif command -v dnf >/dev/null; then
        dnf install -y "$package" &> /dev/null
    else
        errorlog "No suitable package manager found. Please install $package manually."
        exit 1
    fi
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

# Check and install Docker
if ! command -v docker >/dev/null; then
    infolog "Installing docker.io"
    install_package docker.io
    if ! command -v docker >/dev/null; then
        errorlog "Docker installation failed, try manually."
        exit 1
    else
        successlog "Docker installed."
    fi
else
    infolog "Docker found."
fi

# Check and install Git
if ! command -v git >/dev/null; then
    infolog "Installing git"
    install_package git
    if ! command -v git >/dev/null; then
        errorlog "Git installation failed, try manually."
        exit 1
    else
        successlog "Git installed."
    fi
else
    infolog "Git found."
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