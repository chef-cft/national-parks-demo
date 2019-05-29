#!/bin/bash
set -eu -o pipefail

export ssh_user
export ssh_key
export a2_ip

eval "$(jq -r '@sh "export ssh_user=\(.ssh_user) ssh_key=\(.ssh_key) a2_ip=\(.a2_ip)"')"

scp -i ${ssh_key} ${ssh_user}@${a2_ip}:/home/${ssh_user}/automate-credentials.toml $HOME/automate-credentials-${a2_ip}.toml

a2_admin="$(cat $HOME/automate-credentials-${a2_ip}.toml | sed -n -e 's/^username = //p' | tr -d '"')"
a2_password="$(cat $HOME/automate-credentials-${a2_ip}.toml | sed -n -e 's/^password = //p' | tr -d '"')"
a2_token="$(cat $HOME/automate-credentials-${a2_ip}.toml | sed -n -e 's/^api-token = //p' | tr -d '"')"
a2_url="$(cat $HOME/automate-credentials-${a2_ip}.toml | sed -n -e 's/^url = //p' | tr -d '"')"

jq -n --arg a2_admin "$a2_admin" \
      --arg a2_password "$a2_password" \
      --arg a2_token "$a2_token" \
      --arg a2_url "$a2_url" \
      '{"a2_admin":$a2_admin,"a2_password":$a2_password,"a2_token":$a2_token,"a2_url":$a2_url}'
