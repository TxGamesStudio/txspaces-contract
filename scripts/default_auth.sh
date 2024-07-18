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
# sozo -P $profile auth grant writer --fee-estimate-multiplier 5 \
#     UserData,$(get_contract_address "txspaces::systems::user::User") \
#     Character,$(get_contract_address "txspaces::systems::user::User") \
#     CharacterLevel,$(get_contract_address "txspaces::systems::user::User") \
#     InvitationCode,$(get_contract_address "txspaces::systems::user::User") \
#     Random,$(get_contract_address "txspaces::systems::user::User")
# sleep 420

sozo -P $profile auth grant writer --fee-estimate-multiplier 5 \
    UserData,$(get_contract_address "txspaces::systems::game_actions::GameActions") \
    Character,$(get_contract_address "txspaces::systems::game_actions::GameActions") \
    CharacterLevel,$(get_contract_address "txspaces::systems::game_actions::GameActions") \
    InvitationCode,$(get_contract_address "txspaces::systems::game_actions::GameActions") \
    Random,$(get_contract_address "txspaces::systems::game_actions::GameActions")
# sleep 420

# sozo -P $profile auth grant writer --fee-estimate-multiplier 5 \
#     InvitationCode,$(get_contract_address "txspaces::systems::admin::Admin") \
#     Random,$(get_contract_address "txspaces::systems::admin::Admin")

echo "Default authorizations have been successfully set."
