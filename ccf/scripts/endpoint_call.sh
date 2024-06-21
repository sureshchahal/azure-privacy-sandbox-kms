#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

set -e

IS_COSE=0

if [ -z "$NODE_ADDRESS" ]; then
    echo "NODE_ADDRESS is not set. Defaulting to localhost:8080"
    NODE_ADDRESS="localhost:8080"
fi
if [ -n "$MSG_TYPE" ]; then
    IS_COSE=1
fi
if [ -z "$CONTENT_PATH" ]; then
    touch /tmp/empty_file
    CONTENT_PATH="/tmp/empty_file"
fi
if [ -z "$METHOD" ]; then
    METHOD="GET"
fi

if [ -z "$1" ]; then
    echo "Please call with a positional arg for the endpoint to call"
    exit 1
fi
ENDPOINT=$1

if [ $IS_COSE -eq 0 ]; then
    curl -k https://$NODE_ADDRESS/$ENDPOINT
else
    ccf_cose_sign1 \
    --ccf-gov-msg-type $MSG_TYPE \
    --ccf-gov-msg-created_at `date -uIs` \
    --signing-key certs/member0_privk.pem \
    --signing-cert certs/member0_cert.pem \
    --content $CONTENT_PATH \
    | curl -k https://$NODE_ADDRESS/$ENDPOINT \
    -X $METHOD \
    -H "content-type: application/cose" \
    --data-binary @- \
    --cacert service_cert.pem \
    --key certs/member0_privk.pem \
    --cert certs/member0_cert.pem
fi
