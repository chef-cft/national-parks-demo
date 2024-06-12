#!/usr/bin/env bash

printf "Running Command:\n"
printf "\e[1mchef-run \`terraform output dca_public_ips\` effortless_dca::detect --user centos\e[0m\n"

if [ -z "$1" ]
then
chef-run `terraform output dca_public_ips` effortless_dca::detect --user centos 
else
chef-run `terraform output dca_public_ips` effortless_dca::detect --user centos -i $1
fi