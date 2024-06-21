#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

set -e

if [ -n "$1" ]; then
    CCF_PLATFORM=$1
fi
if [ -z "$CCF_PLATFORM" ]; then
    echo "CCF_PLATFORM is not set."
    exit 1
fi

echo "Running ${CCF_PLATFORM}-ccf container"
logs=$(docker compose run --build -d $CCF_PLATFORM-ccf 2>&1)
container_id=$(echo $logs | awk '{print $NF}')
echo "  Container ID: $container_id"

check_logs() {
    docker logs $container_id | grep -q "Network TLS connections now accepted"
}
until check_logs; do
    sleep 1
done

member_id=$(curl -k https://localhost:8080/gov/members --silent | jq -r 'keys | .[0]')
echo "  Initial Member ID: $member_id"
echo $member_id > certs/member0_id

curl -k https://localhost:8080/node/network --silent | jq -r '.service_certificate' > certs/service_cert.pem