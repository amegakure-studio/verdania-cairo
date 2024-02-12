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
    use verdania::constants::{tile_state_1, env_entity_state_1, MAP_1_ID};
    use verdania::store::{Store, StoreTrait};
    use verdania::constants::{ERC20_CONTRACT_ID, ERC1155_CONTRACT_ID, MARKETPLACE_CONTRACT_ID};
    use verdania::interfaces::IERC1155::{IERC1155DispatcherTrait, IERC1155Dispatcher};
    use verdania::interfaces::IERC20::{IERC20Dispatcher, IERC20DispatcherTrait};

    #[abi(embed_v0)]
    impl FarmFactory of IFarmFactorySystem<ContractState> {
        fn create_farm(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let player = get_caller_address();
            let player_farm_state = store.get_player_farm_state(MAP_1_ID, player);
            assert(player_farm_state.farm_id == 0, 'Err: already own a farm');

            // -- CREAR FARM --
            // Crear TileState
            // Crear EnvEntityState
            // Crear PlayerFarmState
            // Crear PlayerState
            // Mint items
            // Mint de money

            let mut farm_count = store.get_farm_count(FARM_COUNT_KEY);
            farm_count.index += 1;
            store.set_farm_count(farm_count);

            // Crear TileState
            let mut tiles_state = tile_state_1(farm_count.index);
            loop {
                match tiles_state.pop_front() {
                    Option::Some(tile_state) => store.set_tile_state(*tile_state),
                    Option::None => { break; }
                }
            };

            // Crear EnvEntityState
            let mut envs_entity_state = env_entity_state_1(farm_count.index);
            let env_entities_len = envs_entity_state.len();
            loop {
                match envs_entity_state.pop_front() {
                    Option::Some(env_entity_state) => store.set_env_entity_state(*env_entity_state),
                    Option::None => { break; }
                }
            };

            // Crear PlayerFarmState
            store
                .set_player_farm_state(
                    PlayerFarmState {
                        player,
                        map_id: MAP_1_ID,
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
                        x: 30, // donde hace spawn el personaje
                        y: 15,
                        equipment_item_id: 1,
                        tokens: 0,
                        last_timestamp_activity: starknet::get_block_timestamp()
                    }
                );

            // Mint items
            let erc1155 = store.get_global_contract(ERC1155_CONTRACT_ID);
            // Tools
            IERC1155Dispatcher { contract_address: erc1155.address }.mint(player, 1, 1);
            IERC1155Dispatcher { contract_address: erc1155.address }.mint(player, 2, 1);
            IERC1155Dispatcher { contract_address: erc1155.address }.mint(player, 3, 1);
            IERC1155Dispatcher { contract_address: erc1155.address }.mint(player, 4, 1);
            IERC1155Dispatcher { contract_address: erc1155.address }.mint(player, 5, 1);

            // Seed
            IERC1155Dispatcher { contract_address: erc1155.address }.mint(player, 6, 10);
            IERC1155Dispatcher { contract_address: erc1155.address }.mint(player, 7, 10);

            // Mint de money
            let erc20 = store.get_global_contract(ERC20_CONTRACT_ID);
            IERC20Dispatcher { contract_address: erc20.address }.mint(player, 1000);
        }
    }
}
