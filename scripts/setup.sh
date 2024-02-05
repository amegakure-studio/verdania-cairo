#!/bin/bash

set -e

echo "sozo build && sozo migrate"
output=$(sozo build && sozo migrate --rpc-url http://0.0.0.0:5050)

contract_addresses=$(echo "$output" | awk '/Contract address/ {print $NF}')
world_address=$(echo "$output" | awk '/Successfully migrated World at address/ {print $NF}')

erc1155=$(echo "$contract_addresses" | awk 'NR==3')
erc20=$(echo "$contract_addresses" | awk 'NR==4')
marketplace=$(echo "$contract_addresses" | awk 'NR==5')
crop_system=$(echo "$contract_addresses" | awk 'NR==6')
env_entity_system=$(echo "$contract_addresses" | awk 'NR==7')
farm_factory_system=$(echo "$contract_addresses" | awk 'NR==8')
item_system=$(echo "$contract_addresses" | awk 'NR==9')
map_system=$(echo "$contract_addresses" | awk 'NR==10')
world_config_system=$(echo "$contract_addresses" | awk 'NR==11')

echo -e "\nSystems: "
echo "erc1155: $erc1155"
echo "erc20: $erc20"
echo "marketplace: $marketplace"
echo "crop_system: $crop_system"
echo "env_entity_system: $env_entity_system" 
echo "farm_factory_system: $farm_factory_system"
echo "item_system: $item_system"
echo "map_system: $map_system"
echo "world_config_system: $world_config_system"
echo -e "\n🎉 World Address: $world_address"

echo -e "\n Setup ..."

# Init

# set global contracts (ERC20, ERC1155, marketplace)
sozo execute ${world_config_system} init_global_contracts -c 3,23588828915041553345745097173581313296708,0x35b72d737f1dd39efb4fd3f03b48ccc93d021323fcae3118847d1883fa7cbcc,1545917490451274575681179362113681226280683844,0x76b450603664806f58e690f48ec0007617f4724102d63af9503a6892e3639a5,7399574450516941475902137329108170261525607675965950276,0x45ab71ec33d6048a970b40b49a7bdbe85e64dc3f3a0b34b593277d2b58846d9 --rpc-url http://0.0.0.0:5050
sleep 3

# erc20
sozo execute ${erc20} init -c 1145130053,4473164,10000,0 --rpc-url http://0.0.0.0:5050
sleep 3

# erc1155 
sozo execute ${erc1155} init --rpc-url http://0.0.0.0:5050

echo -e "\n✅ Setup finish!"

echo -e "\n✅ Init Torii!"
torii --world ${world_address}