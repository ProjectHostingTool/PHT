echo -e "
$(log.info "Commands list. Press ${RED}q ${RESET}to exit, press ${GREEN}arrows(↑ ↓ ← →)${RESET} to navigate.")
$(setline)
${CYAN}get     : ${WHITE}Install a module from url 
\t${MAGENTA}Usage -> ${WHITE} pht get <module github url>
\t${MAGENTA}Ex    -> ${WHITE} pht get ProjectHostingTool/template

${CYAN}run     : ${WHITE}run installed module
\t${MAGENTA}Usage -> ${WHITE} pht run <module name> <params:optional>
\t${MAGENTA}Usage -> ${WHITE} pht run <module name> -c <params:mandatory>

${CYAN}stop    : ${WHITE}stop running module
\t${MAGENTA}Usage -> ${WHITE} pht stop <module name>

${CYAN}list    : ${WHITE}Get list the modules
\t${MAGENTA}Usage -> ${WHITE} pht list

${CYAN}status  : ${WHITE}Get status information of module
\t${MAGENTA}Usage -> ${WHITE} pht status <module name>

${CYAN}remove  : ${WHITE}remove the module
\t${MAGENTA}Usage -> ${WHITE} pht remove <module name>

${CYAN}install : ${WHITE}install the module
\t${MAGENTA}Usage -> ${WHITE} pht install <path/*.pht>
$(setline)
${GREEN}--update  : ${WHITE}Get latest updates of PHT using git automatization.
\t${MAGENTA}Usage ->${WHITE} pht --update

${RED}--uninstall : ${WHITE}Uninstall the PHT and all modules.
\t${MAGENTA}Usage -> ${WHITE} pht --uninstall
\t${MAGENTA}Usage -> ${YELLOW}WARNING, ${WHITE}there is no any question for ${GREEN}apporving to proccess.
" | less -R