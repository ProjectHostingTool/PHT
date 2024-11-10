#!/bin/bash

if ! [ "$UID" -eq 0 ]; then
    echo "Please run this script with sudo or as root."
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
    echo -e "${RESET_COLOR}[${YELLOW}WARN${RESET_COLOR}] $1" && sleep 0.2
}
successlog() {
    echo -e "${RESET_COLOR}[${GREEN}SUCCESS${RESET_COLOR}] $1" && sleep 0.2
}
infolog() {
    echo -e "${RESET_COLOR}[${CYAN}INFO${RESET_COLOR}] $1" && sleep 0.2
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


check_and_install() {
    if ! command -v $1 >/dev/null; then
        infolog "Installing $2"
        install_package $2
        if ! command -v $1 >/dev/null; then
            errorlog "$2 installation failed, try manually."
            exit 1
        else
            successlog "$2 installed."
        fi
    else
        infolog "$2 found."
    fi
}

# Update package lists
apt update &> /dev/null

! command -v curl >/dev/null && install_package install curl &> /dev/null

curl https://raw.githubusercontent.com/ProjectHostingTool/PHT/main/src/colors.lib -s -o /tmp/colors.sh
if [[ $(cat "/tmp/colors.sh" | head -n5) =~ "# Define color variables" ]]; then
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
check_and_install docker docker.io

# Check and install Git
check_and_install git git

# Check and install Less
check_and_install less less

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

echo -e "sudo bash /opt/PHT/main.sh \$@" > /bin/pht
echo -e 'echo -e "Maybe you looking for /bin/pht, right?"' > /bin/pth
chmod +x /bin/pht
mkdir /opt/PHT/core/modules/confs &> /dev/null

[[ -f setup.sh ]] && rm setup.sh
rm /tmp/colors.sh

cd PHT/
git rm -r --cached  core/modules/

successlog "System files installed."
exit 0 