echo -e "${CYAN}|----------[PULL | MAIN]----------|${RESET_COLOR}"
git pull origin main 1> /dev/null 2> /tmp/pht-update.log

if [[ $? == 0 ]]; then
    log.submessage "PHT is Up to date"
else
    log.submessage "Update Fail."
    echo -ne "Do you want to view process log? (y/N)"
    read -e updatelogchoie
    [[ $updatelogchoie =~ ^(y|Y) ]] && cat "/tmp/pht-update.log" | less
    exit 1
fi