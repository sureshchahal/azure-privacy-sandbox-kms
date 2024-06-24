#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

set -e

if [ -z "$NODE_ADDRESS" ]; then
    echo "NODE_ADDRESS is not set."
    exit 1
fi

member_id=$(curl -k https://$NODE_ADDRESS/gov/members --silent | jq -r 'keys | .[0]')
echo "Initial Member ID: $member_id"
echo $member_id > certs/member0_id

curl -k https://$NODE_ADDRESS/node/network --silent | jq -r '.service_certificate' > certs/service_cert.pem
sudo chown -R $USER certs

echo "Network started and is in the 'opening' state"
echo "Next Steps: "
echo "  - Activate the initial member with:"
echo "      'make member-activate member-id=$member_id'"
echo "  - Open the network with 'make network-open'"