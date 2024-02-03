use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IFarmFactorySystem<TContractState> {
    fn create_farm(ref self: TContractState);
}

#[dojo::contract]
mod farm_factory_system {
    use core::array::SpanTrait;
    use super::IFarmFactorySystem;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::models::data::game::{FarmCount, FARM_COUNT_KEY};
    use verdania::models::entities::crop::Crop;
    use verdania::models::states::player_state::PlayerState;
    use verdania::models::states::player_farm_state::PlayerFarmState;
    use verdania::constants::{tile_state_1, env_entity_state_1};
    use verdania::store::{Store, StoreTrait};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl FarmFactory of IFarmFactorySystem<ContractState> {
        fn create_farm(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let player = get_caller_address();

            let map_id = 1;
            let player_farm_state = store.get_player_farm_state(map_id, player);
            assert(player_farm_state.farm_id == 0, 'Err: already own a farm');

            let mut farm_count = store.get_farm_count(FARM_COUNT_KEY);
            farm_count.index += 1;
            store.set_farm_count(farm_count);

            // Crear EnvEntityState
            let mut envs_entity_state = env_entity_state_1(farm_count.index);
            let env_entities_len = envs_entity_state.len();
            loop {
                match envs_entity_state.pop_front() {
                    Option::Some(env_entity_state) => store.set_env_entity_state(*env_entity_state), 
                    Option::None => { break; }
                }
            };

            // Crear TileState
            let mut tiles_state = tile_state_1(farm_count.index);
            loop {
                match tiles_state.pop_front() {
                    Option::Some(tile_state) => store.set_tile_state(*tile_state), 
                    Option::None => { break; }
                }
            };

            // Crear PlayerFarmState
            store
                .set_player_farm_state(
                    PlayerFarmState {
                        player,
                        map_id,
                        farm_id: farm_count.index,
                        name: '',
                        crops_len: 0,
                        env_entities_len: env_entities_len.into(),
                        connected_players: 0,
                        open: true,
                        invitation_code: 0
                    }
                );

            // Crear PlayerState 
            store
                .set_player_state(
                    PlayerState {
                        player,
                        farm_id: farm_count.index,
                        x: 30,
                        y: 15,
                        equipment_item_id: 0,
                        tokens: 0
                    }
                );
            // Crear AccountPlayerState 
        }
    }
}
