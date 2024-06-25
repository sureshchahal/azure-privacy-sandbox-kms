#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

set -e

# Workaround for JS_BUNDLE being too big for envsubst
if grep -q '\${JS_BUNDLE}' "$1"; then
  echo '{
    "actions": [
      {
        "name": "set_js_app",
        "args": {
          "bundle": ' > /tmp/request.json

  cat ../dist/bundle.json >> /tmp/request.json

  echo ',
          "disable_bytecode_cache": false
        }
      }
    ]
  }' >> /tmp/request.json
else
  cat $1 | envsubst > /tmp/request.json
fi

cat /tmp/request.json \
  | awk '{print substr($0, 1, 400) (length($0) > 400 ? "..." : "")}'

MSG_TYPE=proposal \
CONTENT_PATH=/tmp/request.json \
METHOD="POST" \
    ./scripts/endpoint_call.sh gov/members/proposals:create?api-version=2023-06-01-preview