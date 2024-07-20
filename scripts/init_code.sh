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

sozo execute -P $profile --fee-estimate-multiplier 5 txspaces::systems::admin::Admin add_default_code -c 0x10 --wait
sleep 420
sozo execute -P $profile --fee-estimate-multiplier 5 txspaces::systems::admin::Admin add_default_code -c 0x11 --wait
sleep 420
sozo execute -P $profile --fee-estimate-multiplier 5 txspaces::systems::admin::Admin add_default_code -c 0x12 --wait
sleep 420
sozo execute -P $profile --fee-estimate-multiplier 5 txspaces::systems::admin::Admin add_default_code -c 0x13 --wait
sleep 420
sozo execute -P $profile --fee-estimate-multiplier 5 txspaces::systems::admin::Admin add_default_code -c 0x14 --wait
