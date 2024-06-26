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
if [ -z "$REGISTRY" ]; then
    export REGISTRY="local"
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

curl -k https://$NODE_ADDRESS/node/network --silent | jq -r '.service_certificate' > certs/service_cert.pem
sudo chown -R $USER certs

echo "To activate the initial member, run:"
echo "  make member-activate member=certs/member0"
echo ""
echo "When you're ready, open the network with:"
echo "  make network-open"
echo ""
echo "Once the network is open, you can:"
echo "  - Update the default constitution with:"
echo "      make constitution-update"
echo "  - Deploy application code with:"
echo "      make app-deploy"
