#!/usr/bin/env bash

printf "\e[32;3mPulling in waivers from files/waivers.toml...\e[0m\n"
printf "Running Command:\n"
printf "\e[1mchef-run \`terraform output dca_public_ips\` effortless_dca::waivers --user centos\e[0m\n"

if [ -z "$1" ]
then
chef-run `terraform output dca_public_ips` effortless_dca::waivers --user centos 
else
chef-run `terraform output dca_public_ips` effortless_dca::waivers --user centos -i $1
fi