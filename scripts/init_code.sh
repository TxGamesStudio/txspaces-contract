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

sozo execute -P $profile --fee-estimate-multiplier 5 txspaces_dev::systems::admin::Admin add_default_code -c 0x15 --wait
sleep 420
sozo execute -P $profile --fee-estimate-multiplier 5 txspaces_dev::systems::admin::Admin add_default_code -c 0x16 --wait
sleep 420
sozo execute -P $profile --fee-estimate-multiplier 5 txspaces_dev::systems::admin::Admin add_default_code -c 0x17 --wait
sleep 420
sozo execute -P $profile --fee-estimate-multiplier 5 txspaces_dev::systems::admin::Admin add_default_code -c 0x18 --wait
sleep 420
sozo execute -P $profile --fee-estimate-multiplier 5 txspaces_dev::systems::admin::Admin add_default_code -c 0x19 --wait
sleep 420
sozo execute -P $profile --fee-estimate-multiplier 5 txspaces_dev::systems::admin::Admin add_default_code -c 0x1a --wait
sleep 420
sozo execute -P $profile --fee-estimate-multiplier 5 txspaces_dev::systems::admin::Admin add_default_code -c 0x1b --wait
sleep 420
sozo execute -P $profile --fee-estimate-multiplier 5 txspaces_dev::systems::admin::Admin add_default_code -c 0x1c --wait
sleep 420
sozo execute -P $profile --fee-estimate-multiplier 5 txspaces_dev::systems::admin::Admin add_default_code -c 0x1d --wait
sleep 420
sozo execute -P $profile --fee-estimate-multiplier 5 txspaces_dev::systems::admin::Admin add_default_code -c 0x1e --wait
sleep 420
sozo execute -P $profile --fee-estimate-multiplier 5 txspaces_dev::systems::admin::Admin add_default_code -c 0x1f --wait
