#!/bin/bash

AMI_PREFIX="morpheus"
AMI_TYPES=( "ubuntu20" )
declare -a AMI_NAMES

for amitype in "${AMI_TYPES[@]}"; do
    AMI_NAMES+=("${AMI_PREFIX}-${MORPHEUS_VERSION}-${amitype}")
done
