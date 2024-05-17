#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

while getopts P: flag
do
    case "${flag}" in
        P) profile=${OPTARG};;
    esac
done

# export RPC_URL="http://localhost:5050"

# export WORLD_ADDRESS=$(cat ./manifests/dev/manifest.json | jq -r '.world.address')

get_contract_address() {
    local contract_name=$1
    echo $(cat ./manifests/$profile/manifest.json | jq -r --arg name "$contract_name" '.contracts[] | select(.name == $name ).address')
    # echo $(cat ./manifests/$profile/manifest.json | jq -r --arg name "$contract_name" '.contracts[] | select(.name == $name ).address')
}

echo "---------------------------------------------------------------------------"
echo Profile : $profile
echo "---------------------------------------------------------------------------"

# # enable system -> models authorizations
sozo -P $profile auth grant writer UserData,$(get_contract_address "lethal::systems::user::User")
sleep 1
sozo -P $profile auth grant writer Character,$(get_contract_address "lethal::systems::user::User")
sleep 1
sozo -P $profile auth grant writer CharacterLevel,$(get_contract_address "lethal::systems::user::User")
sleep 1

sozo -P $profile auth grant writer UserData,$(get_contract_address "lethal::systems::game_actions::GameActions")
sleep 1
sozo -P $profile auth grant writer Character,$(get_contract_address "lethal::systems::game_actions::GameActions")
sleep 1
sozo -P $profile auth grant writer CharacterLevel,$(get_contract_address "lethal::systems::game_actions::GameActions")
sleep 1

echo "Default authorizations have been successfully set."
