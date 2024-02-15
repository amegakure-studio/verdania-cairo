#!/bin/bash

set -e

echo "sozo build && sozo migrate"
output=$(sozo build && sozo migrate --rpc-url http://0.0.0.0:5050)

contract_addresses=$(echo "$output" | awk '/Contract address/ {print $NF}')
world_address=$(echo "$output" | awk '/Successfully migrated World at address/ {print $NF}')

jps_system=$(echo "$contract_addresses" | awk 'NR==3')
crop_system=$(echo "$contract_addresses" | awk 'NR==4')
env_entity_system=$(echo "$contract_addresses" | awk 'NR==5')
erc1155_system=$(echo "$contract_addresses" | awk 'NR==6')
erc20_system=$(echo "$contract_addresses" | awk 'NR==7')
farm_system=$(echo "$contract_addresses" | awk 'NR==8')
interact_system=$(echo "$contract_addresses" | awk 'NR==9')
item_system=$(echo "$contract_addresses" | awk 'NR==10')
map_system=$(echo "$contract_addresses" | awk 'NR==11')
marketplace_system=$(echo "$contract_addresses" | awk 'NR==12')
player_system=$(echo "$contract_addresses" | awk 'NR==13')
updater_system=$(echo "$contract_addresses" | awk 'NR==14')
world_config_system=$(echo "$contract_addresses" | awk 'NR==15')

echo -e "\nSystems: "
echo "jps_system: $jps_system"
echo "crop_system: $crop_system"
echo "env_entity_system: $env_entity_system" 
echo "erc1155_system: $erc1155_system"
echo "erc20_system: $erc20_system"
echo "farm_system: $farm_system"
echo "interact_system: $interact_system"
echo "item_system: $item_system"
echo "map_system: $map_system"
echo "marketplace_system: $marketplace_system"
echo "player_system: $player_system"
echo "updater_system: $updater_system"
echo "world_config_system: $world_config_system"
echo -e "\n🎉 World Address: $world_address"

echo -e "\n Setup ..."

# Init

# set global contracts (ERC20, ERC1155, marketplace)
sozo execute ${world_config_system} init_global_contracts -c 3,23588828915041553345745097173581313296708,0x35b72d737f1dd39efb4fd3f03b48ccc93d021323fcae3118847d1883fa7cbcc,1545917490451274575681179362113681226280683844,0x76b450603664806f58e690f48ec0007617f4724102d63af9503a6892e3639a5,7399574450516941475902137329108170261525607675965950276,0x45ab71ec33d6048a970b40b49a7bdbe85e64dc3f3a0b34b593277d2b58846d9 --rpc-url http://0.0.0.0:5050
sleep 3

# erc20
sozo execute ${erc20_system} init -c 1145130053,4473164,10000 --rpc-url http://0.0.0.0:5050
sleep 3

# erc1155 
sozo execute ${erc1155_system} init --rpc-url http://0.0.0.0:5050
sleep 3

# marketplace
sozo execute ${marketplace_system} init --rpc-url http://0.0.0.0:5050
sleep 3

# map
sozo execute ${map_system} init --rpc-url http://0.0.0.0:5050

echo -e "\n✅ Setup finish!"

echo -e "\n✅ Init Torii!"
torii --world ${world_address}