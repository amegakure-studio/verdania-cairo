use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IInteractSystem<TContractState> {
    fn init(ref self: TContractState);
    fn interact(ref self: ContractState, player: ContractAddress, item_id: u64, env_id: u64, grid_id: u64);
}

#[dojo::contract]
mod interact_system {
    use super::IInteractSystem;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::models::entities::crop::{Crop, CropT};
    use verdania::models::entities::item::{Tool};
    use verdania::models::entities::env_entity::{EnvEntity, EnvEntityT, EnvEntityT::{
        Rock,
        Tree,
    }, is_crop};
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

        fn interact(ref self: ContractState, player: ContractAddress, item_id: u64, env_id: u64, grid_id: u64) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            if !store.get_interact(item_id, env_id).can_interact {
                return;
            }

            let tool: Tool = item_id.try_into().expect(Errors::WRONG_ITEM_ID_ERROR);
            let env_entity: EnvEntityT = env_id.try_into().expect(Errors::WRONG_ENV_ENTITY_ERROR);
            match tool {
                Tool::Hoe => {
                    let farm = store.get_player_farm_state(1, player);
                    let map = store.get_map(MAP_1_ID);
                    let tile = store.get_tile(MAP_1_ID, grid_id);
                    let mut tile_state = store.get_tile_state(farm.farm_id, grid_id);

                    if is_suitable_for_crops(tile) && tile_state.entity_type.is_zero() {
                        tile_state.entity_type = EnvEntityT::SuitableForCrop.into();
                        store.set_tile_state(tile_state);
                    }
                },
                Tool::Pickaxe => {
                    if env_entity != EnvEntityT::Rock {
                        return;
                    }
                    // TODO: resolve
                },
                Tool::WateringCan => {
                    if !is_crop(env_entity) {
                        return;
                    }
                    // TODO: resolve
                }
            }
        } 
    }
}
