#!/bin/bash -e

# usage: ./libs/packer_build.sh ${ENV} ${AWS_REGION}
# exmple: ./libs/packer_build.sh dev us-east-1

if [[ ! ${1} ]]
then
    echo "ERR: Environment name must be the first argument."
    exit 1
fi

if [[ ! ${2} ]]
then
    echo "ERR: AWS region must be defined."
    exit 1
fi

PROJ_HOME=$(pwd)

cd "${PROJ_HOME}/packer/aws/${1}"
packer build \
-var "env=${1}" \
-var "region=${2}" \
.

cd "${PROJ_HOME}"
