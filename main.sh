#!/bin/bash

if ! [ "$UID" -eq 0 ]; then
    echo "You are not running as root. Please run this script with sudo or as root."
    exit 1
fi

# Main script logic
callerwd="$(pwd)"
#cd /opt/PHT/
touch /tmp/phtanimation.status &> /dev/null
source src/logging.lib
source src/colors.lib
source src/functions.sh
source config.cfg

[[ "$1" =~ (-V|-v) ]] && echo -e "$VERSION" && exit 0
[[ "$@" =~ "--update" ]] && runupdate && exit 0
[[ "$@" =~ "--uninstall" ]] && source core/uninstall.sh  && exit 0
[[ "$@" =~ "--help" ]] && source core/help.sh && exit 0

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
    *)           caseelse                     ;;
esac