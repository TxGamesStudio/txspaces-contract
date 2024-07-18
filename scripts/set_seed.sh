#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

while getopts P: flag
do
    case "${flag}" in
        P) profile=${OPTARG};;
    esac
done

get_contract_address() {
    local contract_name=$1
    echo $(cat ./manifests/$profile/manifest.json | jq -r --arg name "$contract_name" '.contracts[] | select(.name == $name ).address')
    # echo $(cat ./manifests/$profile/manifest.json | jq -r --arg name "$contract_name" '.contracts[] | select(.name == $name ).address')
}

echo "---------------------------------------------------------------------------"
echo Profile : $profile
echo "---------------------------------------------------------------------------"

sozo execute -P $profile txspaces::systems::admin::Admin seed -c 0x225b37d944ce341856ed7d2c82b9bdef --wait
