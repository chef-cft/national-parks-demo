#!/bin/bash
echo making admin token via cli
export TOKEN=`sudo chef-automate iam token create cli --admin`

echo setting speciifc token value via API

curl -X POST \
  https://localhost/apis/iam/v2/tokens \
  --insecure \
  -H "api-token: $TOKEN" \
  -d '{"name":"national-parks","value": "${automate_token}","active": true, "id": "national-parks"}'

echo setting API policies

curl -s \
  https://localhost/apis/iam/v2/policies/ingest-access/members:add \
  --insecure \
  -H "api-token: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"members":["token:national-parks"]}'