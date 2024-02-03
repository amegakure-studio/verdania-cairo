use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IFarmFactorySystem<TContractState> {
    fn create_farm(ref self: TContractState, player: felt252);
}

#[dojo::contract]
mod farm_factory_system {
    use super::IFarmFactorySystem;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::models::data::game::{FarmCount, FARM_COUNT_KEY};
    use verdania::models::entities::crop::Crop;
    use verdania::models::states::player_state::PlayerState;
    use verdania::models::states::player_farm_state::PlayerFarmState;
    use verdania::store::{Store, StoreTrait};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl FarmFactory of IFarmFactorySystem<ContractState> {
        fn create_farm(ref self: ContractState, player: felt252) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let map_id = 1;
            let player_farm_state = store.get_player_farm_state(map_id, player.try_into().unwrap());
            assert(player_farm_state.farm_id == 0 , 'Err: farm exist');

            let mut farm_count = store.get_farm_count(FARM_COUNT_KEY);
            farm_count.index += 1;
            store.set_farm_count(farm_count);

            // Crear EnvEntityState 
            // Crear TileState
            
            // Crear PlayerFarmState
            store.set_player_farm_state(
                PlayerFarmState {
                    player: player.try_into().unwrap(),
                    map_id,
                    farm_id: farm_count.index,
                    name: '',
                    crops_len: 0,
                    entities_len: 0, // TODO:
                    connected_players: 0,
                    open: true,
                    invitation_code: 0
                }
            );
            
            // Crear PlayerState 
            store.set_player_state(
                PlayerState {
                    player: player.try_into().unwrap(),
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
