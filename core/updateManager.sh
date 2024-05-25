#!/bin/sh
echo -e "${CYAN}|----------[PULL | MAIN]----------|${RESET}"
git stash
git pull origin main && git stash clear
