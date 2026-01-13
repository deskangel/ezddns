#!/bin/bash

API_TOKEN=$(cat ~/.config/cloudflare/api_token)
ZONE_ID=$(cat ~/.config/cloudflare/zone_id)
DOMAIN=$(cat ~/.config/cloudflare/domain)
RECORD_ID=$(cat ~/.config/cloudflare/record_id)

if [[ $(uname) == "Darwin" ]]; then
    IP=$(ifconfig | grep 'inet6' | grep -v 'fe80' | grep -v '::1' | grep -v 'temporary' | grep -v 'deprecated' | awk '{print $2}' | head -n 1)
elif [[ $(uname) == "Linux" ]]; then
    IP=$(ip -6 addr show | grep 'scope global' | grep -v 'temporary' | awk '{print $2}' | cut -d'/' -f1 | head -n 1)
else
    echo "Unsupported OS"
    exit 1
fi

/usr/bin/curl -s -S -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json" \
     --data "{\"type\":\"AAAA\",\"name\":\"$DOMAIN\",\"content\":\"$IP\",\"ttl\":120}"

if [ $? -eq 0 ]; then
    echo "IP updated to: $IP"
else
    echo "Ip update failed"
fi
