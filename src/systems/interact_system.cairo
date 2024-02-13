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
    use verdania::models::entities::item::{
        Tool, Seed, equip_item_is_a_seed, get_crop_id_from_seed
    };
    use verdania::models::entities::env_entity::{
        EnvEntity, EnvEntityT, EnvEntityT::{Rock, Tree,}, is_crop
    };
    use verdania::models::states::{player_farm_state::PlayerFarmState, player_state::PlayerState, crop_state::CropState};
    use verdania::constants::ERC1155_CONTRACT_ID;
    use verdania::interfaces::IERC1155::{IERC1155DispatcherTrait, IERC1155Dispatcher};
    use verdania::models::entities::tile::is_suitable_for_crops;
    use verdania::models::entities::map::Map;
    use verdania::constants::{MAP_1_ID, ACTIVE_PLAYERS_LEN_ID};
    use verdania::store::{Store, StoreTrait};
    use verdania::models::states::active_players::{ActivePlayers, ActivePlayersLen};

    #[storage]
    struct Storage {}

    mod Errors {
        const WRONG_ITEM_ID_ERROR: felt252 = 'Interact: item isnt a tool';
        const WRONG_ENV_ENTITY_ERROR: felt252 = 'Interact: env entity';
    }

    #[abi(embed_v0)]
    impl InteractSystem of IInteractSystem<ContractState> {
        fn init(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);
        }

        fn interact(ref self: ContractState, player: ContractAddress, grid_id: u64) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let player_state = store.get_player_state(player);
            let map = store.get_map(MAP_1_ID);
            let mut farm = store.get_player_farm_state(MAP_1_ID, player);
            let mut tile_state = store.get_tile_state(farm.farm_id, grid_id);

            if !player_is_adjacent(map, player_state, grid_id) {
                return;
            }

            if !store
                .get_interact(player_state.equipment_item_id, tile_state.entity_type)
                .can_interact {
                return;
            }

            let env_entity: EnvEntityT = tile_state
                .entity_type
                .try_into()
                .expect(Errors::WRONG_ENV_ENTITY_ERROR);
            if is_crop(env_entity) {
                let mut crop_state = store.get_crop_state(farm.farm_id, tile_state.entity_index);

                // Ready for collect
                if crop_state.growing_progress == 100 {
                    let mut env_entity_details = store.get_env_entity(tile_state.entity_type);
                    add_item(
                        ref store,
                        player,
                        env_entity_details.drop_item_id,
                        env_entity_details.quantity
                    );

                    crop_state.harvested = true;
                    store.set_crop_state(crop_state);

                    tile_state.entity_type = Zeroable::zero();
                    tile_state.entity_index = Zeroable::zero();
                    store.set_tile_state(tile_state);

                    // Add crop to farm
                    farm.crops_len -= 1;
                    store.set_player_farm_state(farm);

                    return;
                }
            }

            if equip_item_is_a_seed(player_state.equipment_item_id)
                && env_entity == EnvEntityT::SuitableForCrop {
                remove_item(ref store, player, player_state.equipment_item_id, 1);
                let map = store.get_map(MAP_1_ID);
                let (y, x) = integer::u64_safe_divmod(grid_id, integer::u64_as_non_zero(map.width));
                let crop_id_from_seed = get_crop_id_from_seed(player_state.equipment_item_id);

                let new_crop_state = CropState {
                    farm_id: farm.farm_id,
                    index: Zeroable::zero(), // this should be setted later on add_or_replace_free
                    crop_id: crop_id_from_seed,
                    x: x,
                    y: y,
                    growing_progress: Zeroable::zero(),
                    planting_time: starknet::get_block_timestamp(),
                    last_watering_time: starknet::get_block_timestamp(),
                    harvested: false,
                };

                let new_index = get_crop_state_unused_id(ref store, farm, new_crop_state);
                // update tile state with new crop
                // TODO: check tile_state.entity_type
                tile_state.entity_type = crop_id_from_seed;
                tile_state.entity_index = new_index;
                store.set_tile_state(tile_state);

                // Add crop to farm
                farm.crops_len += 1;
                store.set_player_farm_state(farm);

                return;
            }

            let tool: Tool = player_state
                .equipment_item_id
                .try_into()
                .expect(Errors::WRONG_ITEM_ID_ERROR);
            match tool {
                Tool::Hoe => {
                    let map = store.get_map(MAP_1_ID);
                    let tile = store.get_tile(MAP_1_ID, grid_id);

                    if is_suitable_for_crops(tile) && tile_state.entity_type.is_zero() {
                        tile_state.entity_type = EnvEntityT::SuitableForCrop.into();
                        store.set_tile_state(tile_state);
                    }
                },
                Tool::Pickaxe => {
                    if env_entity != EnvEntityT::Rock {
                        return;
                    }
                    let mut env_entity_details = store.get_env_entity(tile_state.entity_type);
                    add_item(
                        ref store,
                        player,
                        env_entity_details.drop_item_id,
                        env_entity_details.quantity
                    );

                    tile_state.entity_type = Zeroable::zero();
                    tile_state.entity_index = Zeroable::zero();
                    store.set_tile_state(tile_state);
                },
                Tool::WateringCan => {
                    if !is_crop(env_entity) {
                        return;
                    }
                    let mut crop_state = store
                        .get_crop_state(farm.farm_id, tile_state.entity_index);
                    crop_state.last_watering_time = starknet::get_block_timestamp();
                    store.set_crop_state(crop_state);
                }
            }
            // reset AFK time
            let active_players_len = store.get_active_players_len();
            store.set_active_player(ActivePlayers { idx: active_players_len.len + 1, player: player, last_timestamp_activity: starknet::get_block_timestamp() });
            store.set_active_players_len(ActivePlayersLen { key: ACTIVE_PLAYERS_LEN_ID, len: active_players_len.len + 1 });
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
            .safe_transfer_from(
                player, Zeroable::zero(), item_id.into(), quantity.into(), array![]
            );
    }

    fn player_is_adjacent(map: Map, player_state: PlayerState, grid_id: u64) -> bool {
        let (gy, gx) = integer::u64_safe_divmod(grid_id, integer::u64_as_non_zero(map.width));
        let px = player_state.x;
        let py = player_state.y;
        let dx = if px > gx { px - gx } else { gx - px };
        let dy = if py > gy { py - gy } else { gy - py };
        (dx == 1 && dy == 0) || (dx == 0 && dy == 1) || (dx == 1 && dy == 1)
    }

    fn get_crop_state_unused_id(
        ref store: Store, farm: PlayerFarmState, crop_state: CropState
    ) -> u64 {
        let mut i = 0;
        let mut unused_space = false;
        loop {
            if farm.crops_len == i {
                break;
            }
            let stored_crop_state = store.get_crop_state(farm.farm_id, i);
            if stored_crop_state.harvested {
                unused_space = true;
                break;
            }
            i += 1;
        };
        if unused_space {
            i
        } else {
            farm.crops_len + 1
        }
    }
}
