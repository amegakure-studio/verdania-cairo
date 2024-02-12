use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

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
    use verdania::models::entities::item::{Tool, Seed, equip_item_is_a_seed};
    use verdania::models::entities::env_entity::{EnvEntity, EnvEntityT, EnvEntityT::{
        Rock,
        Tree,
    }, is_crop};
    use verdania::constants::ERC1155_CONTRACT_ID;
    use verdania::interfaces::IERC1155::{
        IERC1155DispatcherTrait, IERC1155Dispatcher
    };
    use verdania::models::entities::tile::is_suitable_for_crops;
    use verdania::constants::MAP_1_ID;
    use verdania::store::{Store, StoreTrait};

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
            let farm = store.get_player_farm_state(MAP_1_ID, player);
            let mut tile_state = store.get_tile_state(farm.farm_id, grid_id);

            if !store.get_interact(player_state.equipment_item_id, tile_state.entity_type).can_interact {
                return;
            }

            let env_entity: EnvEntityT = tile_state.entity_type.try_into().expect(Errors::WRONG_ENV_ENTITY_ERROR);
            if is_crop(env_entity) {
                let mut crop_state = store.get_crop_state(farm.farm_id, tile_state.entity_index);
                // Ready for collect
                if crop_state.growing_progress == 100 {
                    let mut env_entity_details = store.get_env_entity(tile_state.entity_type);
                    let erc1155 = store.get_global_contract(ERC1155_CONTRACT_ID); 
                    IERC1155Dispatcher { contract_address: erc1155.address }
                        .mint(player, env_entity_details.drop_item_id.into(), env_entity_details.quantity.into());
                    
                    tile_state.entity_type = Zeroable::zero();
                    tile_state.entity_index = Zeroable::zero();
                    store.set_tile_state(tile_state);

                    return;
                }
            }

            if equip_item_is_a_seed(player_state.equipment_item_id) && env_entity == EnvEntityT::SuitableForCrop {
                let mut env_entity_details = store.get_env_entity(tile_state.entity_type);
                let erc1155 = store.get_global_contract(ERC1155_CONTRACT_ID); 
                IERC1155Dispatcher { contract_address: erc1155.address }
                    .safe_transfer_from(player, Zeroable::zero(), player_state.equipment_item_id.into(), 1, array![]);

                // TODO: Implement
                let item_data = store.get_item(player_state.equipment_item_id);
                // let crop_state
                tile_state.entity_type = item_data.env_entity_id;
                tile_state.entity_index = Zeroable::zero();
                store.set_tile_state(tile_state);
                return;
            }

            let tool: Tool = player_state.equipment_item_id.try_into().expect(Errors::WRONG_ITEM_ID_ERROR);
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

                    let erc1155 = store.get_global_contract(ERC1155_CONTRACT_ID); 
                    IERC1155Dispatcher { contract_address: erc1155.address }
                        .mint(player, env_entity_details.drop_item_id.into(), env_entity_details.quantity.into());
                    
                    tile_state.entity_type = Zeroable::zero();
                    tile_state.entity_index = Zeroable::zero();
                    store.set_tile_state(tile_state);
                },
                Tool::WateringCan => {
                    if !is_crop(env_entity) {
                        return;
                    }
                    let mut crop_state = store.get_crop_state(farm.farm_id, tile_state.entity_index);
                    crop_state.last_watering_time = starknet::get_block_timestamp();
                    store.set_crop_state(crop_state);
                }
            }
        } 
    }
}
