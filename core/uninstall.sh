mpath="/opt/PHT/core/modules"
conflist=("$mpath"/confs/*.conf)

for file in "${conflist[@]}"; do
    confindex "$file"
    pht remove $name
done
rm -r /opt/PHT || warnlog "/opt/PHT can not removed!"
rm /bin/pht
docker network rm phtnetwork &>/dev/null || warnlog "Docker phtnetwork cannot removed!"

infolog "GoodBye :)"
sublog "Github : https://github.com/PlexusNetworkSystem/PHT"