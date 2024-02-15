#!/bin/bash

set -e

echo "sozo build && sozo migrate"
output=$(sozo build && sozo migrate --rpc-url http://0.0.0.0:5050)

contract_addresses=$(echo "$output" | awk '/Contract address/ {print $NF}')
world_address=$(echo "$output" | awk '/Successfully migrated World at address/ {print $NF}')

crop_system=$(echo "$contract_addresses" | awk 'NR==3')
env_entity_system=$(echo "$contract_addresses" | awk 'NR==4')
erc1155_system=$(echo "$contract_addresses" | awk 'NR==5')
erc20_system=$(echo "$contract_addresses" | awk 'NR==6')
farm_factory_system=$(echo "$contract_addresses" | awk 'NR==7')
item_system=$(echo "$contract_addresses" | awk 'NR==8')
map_system=$(echo "$contract_addresses" | awk 'NR==9')
marketplace_system=$(echo "$contract_addresses" | awk 'NR==10')
interact_system=$(echo "$contract_addresses" | awk 'NR==11')
skin_system=$(echo "$contract_addresses" | awk 'NR==11')

echo -e "\nSystems: "
echo "erc1155_system: $erc1155_system"
echo "erc20_system: $erc20_system"
echo "marketplace_system: $marketplace_system"
echo "crop_system: $crop_system"
echo "env_entity_system: $env_entity_system" 
echo "farm_factory_system: $farm_factory_system"
echo "item_system: $item_system"
echo "map_system: $map_system"
echo "interact_system: $interact_system"
echo "skin_system: $skin_system"
echo -e "\n🎉 World Address: $world_address"

echo -e "\n Setup ..."

# Init

# set global contracts (ERC20, ERC1155, marketplace)
sozo execute ${world_config_system} init_global_contracts -c 3,23588828915041553345745097173581313296708,0x35b72d737f1dd39efb4fd3f03b48ccc93d021323fcae3118847d1883fa7cbcc,1545917490451274575681179362113681226280683844,0x76b450603664806f58e690f48ec0007617f4724102d63af9503a6892e3639a5,7399574450516941475902137329108170261525607675965950276,0x45ab71ec33d6048a970b40b49a7bdbe85e64dc3f3a0b34b593277d2b58846d9 --rpc-url http://0.0.0.0:5050
sleep 3

# erc20
sozo execute ${erc20_system} init -c 1145130053,4473164,10000,0 --rpc-url http://0.0.0.0:5050
sleep 3

# erc1155 
sozo execute ${erc1155_system} init --rpc-url http://0.0.0.0:5050

# marketplace
sozo execute ${marketplace_system} init --rpc-url http://0.0.0.0:5050

echo -e "\n✅ Setup finish!"

echo -e "\n✅ Init Torii!"
torii --world ${world_address}