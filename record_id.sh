#!/bin/bash

API_TOKEN=$(cat ~/.config/cloudflare/api_token)
ZONE_ID=$(cat ~/.config/cloudflare/zone_id)
DOMAIN=$(cat ~/.config/cloudflare/domain)

RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$DOMAIN" \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json")

RECORD_ID=$(echo $RESPONSE | jq -r '.result[0].id')
if [ -n "$RECORD_ID" ]; then
    echo "--------------------------------"
    echo "RECORD_ID: $RECORD_ID"
    echo "--------------------------------"
    echo "Please save the RECORD_ID into ~/.config/cloudflare/record_id or copy it to ddns.sh script for use."
else
    echo "Failed, please confirm you have manually created an AAAA record named $DOMAIN in Cloudflare dashboard."
    echo "RESPONSE: $RESPONSE"
fi
