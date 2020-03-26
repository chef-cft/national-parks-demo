#!/bin/bash

echo "Adding hardcoded api token"
export TOKEN=`sudo chef-automate admin-token`

echo "setting automate_token"

curl -X POST \
  https://localhost/api/v0/auth/tokens \
  --insecure \
  -H "api-token: $TOKEN" \
  -d '{"value": "${automate_token}","description": "From Terraform","active": true, "id": "00000000-0000-0000-0000-000000000000"}'

curl -s \
  https://localhost/api/v0/auth/policies \
  --insecure \
  -H "api-token: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"subjects":["token:00000000-0000-0000-0000-000000000000"], "action":"*", "resource":"compliance:*"}'