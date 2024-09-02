mpath="/opt/PHT/core/modules"
conflist=("$mpath"/confs/*.conf)

for file in "${conflist[@]}"; do
    confindex "$file"
    pht remove $name
done
rm -r /opt/PHT || log.warn "/opt/PHT can not removed!"
rm /bin/pht
docker network rm phtnetwork &>/dev/null || log.warn "Docker phtnetwork cannot removed!"

log.info "GoodBye :)"
log.submessage "Github : https://github.com/PlexusNetworkSystem/PHT"