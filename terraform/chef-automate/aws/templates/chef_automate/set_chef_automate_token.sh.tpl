#!/bin/bash
echo making admin token via cli
export TOKEN=`sudo chef-automate iam token create cli --admin`

echo setting speciifc token value via API

curl -X POST \
  https://localhost/apis/iam/v2/tokens \
  --insecure \
  -H "api-token: $TOKEN" \
  -d '{"name":"national-parks", "value": "${automate_token}", "active": true, "id": "national-parks"}'

echo setting API policies

curl -s \
  https://localhost/apis/iam/v2/policies/ingest-access/members:add \
  --insecure \
  -H "api-token: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"members":["token:national-parks"]}'





echo setting speciifc token value via API for pipeline testing

curl -X POST \
  https://localhost/apis/iam/v2/tokens \
  --insecure \
  -H "api-token: $TOKEN" \
  -d '{"name":"pipeline-admin", "value": "${pipeline_admin_token}", "active": true, "id": "pipeline-admin"}'

echo setting API policies for pipeline testing

curl -s \
  https://localhost/apis/iam/v2/policies/administrator-access/members:add \
  --insecure \
  -H "api-token: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"members":["token:pipeline-admin"]}'


curl --location --request GET 'https://localhost/api/v0/cfgmgmt/nodes' \
  --insecure \
  --header 'api-token: ${pipeline_admin_token}' \
  --header 'Content-Type: application/json' \
  --data-raw '{ "threshold_seconds": 3 }'
