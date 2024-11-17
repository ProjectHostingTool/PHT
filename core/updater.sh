echo -e "${CYAN}|----------[PULL | MAIN]----------|${RESET_COLOR}"
git pull origin main &> /dev/null

if [[ $? == 0 ]]; then
    stopanimation "done"
    log.submessage "$name is Up to date"
else
    stopanimation "error"
    log.submessage "Update Fail."
    echo -ne "Do you want to view process log? (y/N)"
    read -e updatelogchoie
    [[ $updatelogchoie =~ ^(y|Y) ]] && cat "/tmp/$name-update.log" | less
    exit 1
fi