#!/bin/bash

url="$2"
# Check the connection
startanimation "Checking Connection" 
response=$(curl -I -s -o /dev/null -w "%{http_code}" "github.com/$url.git")
if [ "$response" -ne 301 ]; then
    stopanimation "error"
    log.submessage "Cloning is not possible!, HTTP status code: $response"
    exit 1
else
    response=$(curl -I -s -o /dev/null -w "%"{http_code} https://raw.githubusercontent.com/$url/main/module.pht)
    if [[ "$response" -ne 200 ]]; then
        stopanimation "error"
        log.submessage "module.pht not found!, HTTP status code: $response"
        exit 1
    else
        stopanimation "done"
        log.submessage "HTTP status code: $response"
    fi
fi

startanimation "Cloning module.pht"
curl -s -f https://raw.githubusercontent.com/$url/main/module.pht -o "/tmp/$(basename $url).pht"
! [[ -f "/tmp/$(basename $url).pht"  ]] && stopanimation "error" && log.submessage "/tmp/$(basename $url).pht not found!" && exit 1
stopanimation "done"
pht install "/tmp/$(basename $url).pht"
rm /tmp/$(basename $url).pht