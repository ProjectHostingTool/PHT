#!/bin/bash

if ! [ "$UID" -eq 0 ]; then
    echo "You are not running as root. Please run this script with sudo or as root."
    exit 1
fi

# Log viewing shortcut
[[ $1 =~ ^(--logs|--log) ]] && cat /opt/PHT/core/logs/* && exit 0

# Main script logic
cd /opt/PHT/
touch /tmp/phtanimation.status &> /dev/null
source src/colors.sh
source src/functions.sh

case "$1" in
    "get")       source core/moduleGet.sh     ;;
    "run")       source core/moduleRun.sh     ;;
    "stop")      source core/moduleStop.sh    ;;
    "list")      source core/moduleList.sh    ;;
    "help")      source core/help.sh          ;;
    "status")    source core/moduleStatus.sh  ;;
    "update")    source core/moduleUpdate.sh  ;;
    "remove")    source core/moduleRemove.sh  ;;
    "install")   source core/moduleInstall.sh ;;
    "--uninstall") source core/uninstall.sh   ;;
    "--update")  runupdate                    ;;
    *)           caseelse                     ;;
esac
