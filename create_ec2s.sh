#!/bin/bash

if [[ $1 == "" ]]; then
    echo "Specify version number as argument"
    exit 1
fi
MORPHEUS_VERSION=$1
source versions.sh

for ami in "${AMI_NAMES[@]}"; do
    ansible-playbook make_ec2.yml -e "ami_name=${ami}"
done
