use verdania::store::{Store, StoreTrait};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use starknet::ContractAddress;

#[starknet::interface]
trait IInteractSystem<TContractState> {
    fn init(ref self: TContractState);
    fn interact(ref self: TContractState, player: ContractAddress, grid_id: u64);
}

#[dojo::contract]
mod interact_system {
    use super::IInteractSystem;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::models::entities::crop::{Crop, CropT};
    use verdania::models::entities::item::{Tool, Seed, equip_item_is_a_seed, get_crop_id_from_seed};
    use verdania::models::entities::env_entity::{
        EnvEntity, EnvEntityT, EnvEntityT::{Rock, Tree,}, is_crop
    };
    use verdania::models::states::{
        player_farm_state::PlayerFarmState, player_state::PlayerState, crop_state::CropState
    };
    use verdania::constants::ERC1155_CONTRACT_ID;
    use verdania::constants::{MAP_1_ID, ACTIVE_PLAYERS_LEN_ID};
    use verdania::models::states::tile_state::{TS_ENVIROMENT_ID, TS_CROP_ID};
    use verdania::models::states::env_entity_state::EnvEntityState;
    use verdania::interfaces::IERC1155::{IERC1155DispatcherTrait, IERC1155Dispatcher};
    use verdania::models::entities::tile::is_suitable_for_crops;
    use verdania::models::entities::map::Map;
    use verdania::models::states::active_players::{ActivePlayers, ActivePlayersLen};
    use verdania::store::{Store, StoreTrait};
    use verdania::models::data::env_entity_id::{
        ENV_SUITABLE_FOR_CROP, ENV_PUMPKIN_ID, ENV_ONION_ID, ENV_CARROT_ID, ENV_CORN_ID,
        ENV_MUSHROOM_ID, ENV_TREE_ID, ENV_ROCK_ID
    };

    mod Errors {
        const WRONG_ENV_ENTITY_ERROR: felt252 = 'cannot obtain env entity tile';
        const WRONG_ITEM_ID_ERROR: felt252 = 'cannot obtain tool from item_id';
        const NON_ADJACENT_ERROR: felt252 = 'player must be adjacent to grid';
        const INTERACTION_NOT_REGISTERED: felt252 = 'interaction doesnt exists';
    }

    #[abi(embed_v0)]
    impl InteractSystem of IInteractSystem<ContractState> {
        fn init(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);
        // TODO: register items interactions
        }

        fn interact(ref self: ContractState, player: ContractAddress, grid_id: u64) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let mut player_state = store.get_player_state(player);
            let map = store.get_map(MAP_1_ID);
            let mut farm = store.get_player_farm_state(MAP_1_ID, player);
            let mut tile_state = store.get_tile_state(farm.id, grid_id);

            assert(player_is_adjacent(map, player_state, grid_id), Errors::NON_ADJACENT_ERROR);

            let current_timestamp = starknet::get_block_timestamp();
            if tile_state.entity_type == TS_CROP_ID {
                let mut crop_state = store.get_crop_state(farm.id, tile_state.entity_index);

                if crop_state.growing_progress == 100 {
                    let mut crop_details = store.get_crop(crop_state.crop_id);

                    add_item(ref store, player, crop_details.drop_item_id, crop_details.quantity);

                    crop_state.harvested = true;
                    store.set_crop_state(crop_state);

                    tile_state.entity_type = Zeroable::zero();
                    tile_state.entity_index = Zeroable::zero();
                    store.set_tile_state(tile_state);

                    let mut env_entity_state = store
                        .get_env_entity_state(farm.id, tile_state.entity_index);
                    env_entity_state.active = false;
                    store.set_env_entity_state(env_entity_state);

                    // Add crop to farm
                    farm.crops_len -= 1;
                    store.set_player_farm_state(farm);
                }
            }

            if equip_item_is_a_seed(player_state.equipment_item_id) {
                let env_entity_state = store.get_env_entity_state(farm.id, tile_state.entity_index);
                if env_entity_state.env_entity_id == ENV_SUITABLE_FOR_CROP {
                    remove_item(ref store, player, player_state.equipment_item_id, 1);

                    let erc1155 = store.get_global_contract(ERC1155_CONTRACT_ID);
                    let seed_balance = IERC1155Dispatcher { contract_address: erc1155.address }
                        .balance_of(player, player_state.equipment_item_id);

                    if seed_balance.is_zero() {
                        player_state.equipment_item_id = 0;
                        store.set_player_state(player_state);
                    }

                    let (y, x) = integer::u64_safe_divmod(
                        grid_id, integer::u64_as_non_zero(map.width)
                    );
                    let crop_id_from_seed = get_crop_id_from_seed(player_state.equipment_item_id);

                    let new_crop_index = get_crop_state_unused_id(ref store, farm);
                    let new_crop_state = CropState {
                        farm_id: farm.id,
                        index: new_crop_index,
                        crop_id: crop_id_from_seed,
                        x: x,
                        y: y,
                        growing_progress: Zeroable::zero(),
                        planting_time: current_timestamp,
                        last_watering_time: current_timestamp,
                        harvested: false,
                    };
                    store.set_crop_state(new_crop_state);

                    let crop_t: CropT = crop_id_from_seed
                        .try_into()
                        .expect('Cannot convert crop_id to CropT');
                    let ee_from_crop: EnvEntityT = crop_t.into();

                    let env_entity_state = EnvEntityState {
                        farm_id: farm.id,
                        index: tile_state.entity_index,
                        env_entity_id: ee_from_crop.into(),
                        x: x,
                        y: y,
                        active: true
                    };
                    store.set_env_entity_state(env_entity_state);

                    tile_state.entity_type = TS_CROP_ID;
                    store.set_tile_state(tile_state);

                    // Add crop to farm
                    farm.crops_len += 1;
                    store.set_player_farm_state(farm);
                }
            }

            // TODO: register interactions
            // assert(
            //     store
            //         .get_interact(player_state.equipment_item_id, tile_state.entity_type)
            //         .can_interact,
            //     Errors::INTERACTION_NOT_REGISTERED
            // );

            let tool: Tool = player_state
                .equipment_item_id
                .try_into()
                .expect(Errors::WRONG_ITEM_ID_ERROR);

            match tool {
                Tool::Hoe => {
                    let tile = store.get_tile(MAP_1_ID, grid_id);
                    if is_suitable_for_crops(tile) && tile_state.entity_type.is_zero() {
                        let (y, x) = integer::u64_safe_divmod(
                            grid_id, integer::u64_as_non_zero(map.width)
                        );

                        let new_tile_state_idx = get_env_entity_state_unused_id(ref store, farm);
                        let env_entity_state = EnvEntityState {
                            farm_id: farm.id,
                            index: new_tile_state_idx,
                            env_entity_id: ENV_SUITABLE_FOR_CROP,
                            x: x,
                            y: y,
                            active: true,
                        };
                        store.set_env_entity_state(env_entity_state);

                        tile_state.entity_type = TS_ENVIROMENT_ID;
                        tile_state.entity_index = new_tile_state_idx;
                        store.set_tile_state(tile_state);
                        
                        farm.env_entities_len += 1;
                        store.set_player_farm_state(farm);
                    }
                },
                // Tool::Pickaxe => {
                //     if tile_state.entity_type != TS_ENVIROMENT_ID {
                //         return;
                //     }

                //     let env_entity_state = store
                //         .get_env_entity_state(farm.id, tile_state.entity_index);
                //     if env_entity_state.env_entity_id != ENV_ROCK_ID {
                //         return;
                //     }

                //     let mut env_entity_details = store.get_env_entity(ENV_ROCK_ID);
                //     add_item(
                //         ref store,
                //         player,
                //         env_entity_details.drop_item_id,
                //         env_entity_details.quantity
                //     );

                //     let (y, x) = integer::u64_safe_divmod(
                //         grid_id, integer::u64_as_non_zero(map.width)
                //     );
                //     let env_entity_state = EnvEntityState {
                //         farm_id: farm.id,
                //         index: tile_state.entity_index,
                //         env_entity_id: Zeroable::zero(),
                //         x: x,
                //         y: y,
                //         active: false,
                //     };
                //     store.set_env_entity_state(env_entity_state);

                //     tile_state.entity_type = Zeroable::zero();
                //     tile_state.entity_index = Zeroable::zero();
                //     store.set_tile_state(tile_state);

                //     farm.env_entities_len -= 1;
                //     store.set_player_farm_state(farm);
                // },
                Tool::WateringCan => {
                    if tile_state.entity_type != TS_CROP_ID {
                        return;
                    }
                    let mut crop_state = store.get_crop_state(farm.id, tile_state.entity_index);
                    crop_state.last_watering_time = current_timestamp;
                    store.set_crop_state(crop_state);
                }
            }
            // TODO: we have to handle this in a better way
            let mut active_players = store.get_verdania_active_players();
            loop {
                if active_players.is_empty() {
                    break;
                }
                let aplayer = *(active_players.pop_front().unwrap());
                if aplayer.player == player {
                    store
                        .set_active_player(
                            ActivePlayers {
                                idx: aplayer.idx, player, last_timestamp_activity: current_timestamp
                            }
                        );
                    break;
                }
            }
        }
    }

    fn add_item(ref store: Store, player: ContractAddress, item_id: u64, quantity: u64) {
        let erc1155 = store.get_global_contract(ERC1155_CONTRACT_ID);
        IERC1155Dispatcher { contract_address: erc1155.address }
            .mint(player, item_id.into(), quantity.into());
    }

    fn remove_item(ref store: Store, player: ContractAddress, item_id: u64, quantity: u64) {
        let erc1155 = store.get_global_contract(ERC1155_CONTRACT_ID);
        IERC1155Dispatcher { contract_address: erc1155.address }
            .safe_transfer_from(player, erc1155.address, item_id.into(), quantity.into(), array![]);
    }

    fn player_is_adjacent(map: Map, player_state: PlayerState, grid_id: u64) -> bool {
        let (gy, gx) = integer::u64_safe_divmod(grid_id, integer::u64_as_non_zero(map.width));
        if player_state.x == gx && player_state.y == gy {
            return true;
        } 
        let px = player_state.x;
        let py = player_state.y;
        let dx = if px > gx {
            px - gx
        } else {
            gx - px
        };
        let dy = if py > gy {
            py - gy
        } else {
            gy - py
        };
        (dx == 1 && dy == 0) || (dx == 0 && dy == 1) || (dx == 1 && dy == 1)
    }

    fn get_crop_state_unused_id(ref store: Store, farm: PlayerFarmState) -> u64 {
        let mut i = 0;
        let mut unused_space = false;
        loop {
            if farm.crops_len == i {
                break;
            }
            let stored_crop_state = store.get_crop_state(farm.id, i);
            if stored_crop_state.harvested {
                unused_space = true;
                break;
            }
            i += 1;
        };
        if unused_space {
            i
        } else {
            farm.crops_len
        }
    }

    fn get_env_entity_state_unused_id(ref store: Store, farm: PlayerFarmState) -> u64 {
        let mut i = 0;
        let mut unused_space = false;
        loop {
            if farm.env_entities_len == i {
                break;
            }
            let stored_env_entity_state = store.get_env_entity_state(farm.id, i);
            if !stored_env_entity_state.active {
                unused_space = true;
                break;
            }
            i += 1;
        };
        if unused_space {
            i
        } else {
            farm.env_entities_len
        }
    }
}
