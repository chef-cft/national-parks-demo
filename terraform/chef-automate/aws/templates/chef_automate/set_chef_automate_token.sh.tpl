#!/bin/bash

if [[ "$(sudo chef-automate iam version)" = "IAM v2."* ]]
then
  export TOKEN=`sudo chef-automate iam token create demo --admin`
  echo version 2.x!
fi

if [ "$(sudo chef-automate iam version)" = 'IAM v1.0' ]
then
  export TOKEN=`sudo chef-automate admin-token`
  echo version 1.0!
fi

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