#!/bin/bash

if ! [ "$UID" -eq 0 ]; then 
    sudo pht $@
    exit 0
fi

# Main script logic
cd /opt/PHT/
touch /tmp/phtanimation.status &> /dev/null
source src/colors.sh
source src/functions.sh
source config.cfg

[[ "$1" =~ ^(-V|-v) ]] && echo -e "$VERSION" && exit 0

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
