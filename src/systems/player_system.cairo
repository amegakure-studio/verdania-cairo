use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IPlayerSystem<TContractState> {
    fn create(
        ref self: TContractState, player: ContractAddress, player_name: felt252, gender_id: u64
    );
    fn equip(ref self: TContractState, player: ContractAddress, item_id: u64);
    fn move(ref self: TContractState, player: ContractAddress, x: u64, y: u64);
}

#[dojo::contract]
mod player_system {
    use super::IPlayerSystem;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::store::{Store, StoreTrait};
    use verdania::models::entities::skin::{PlayerSkin, Gender};
    use verdania::models::entities::item::{Item, Tool, its_a_valid_item};
    use verdania::models::states::tile_state::{TS_ENVIROMENT_ID, TS_CROP_ID};
    use verdania::models::data::env_entity_id::{
        ENV_SUITABLE_FOR_CROP, ENV_PUMPKIN_ID, ENV_ONION_ID, ENV_CARROT_ID, ENV_CORN_ID,
        ENV_MUSHROOM_ID, ENV_TREE_ID, ENV_ROCK_ID, ENV_GRASS_ID
    };
    use verdania::models::entities::map::Map;
    use verdania::models::entities::tile::{Tile, is_walkable};
    use verdania::pathfinding::numbers::integer_trait::IntegerTrait;
    use verdania::pathfinding::numbers::i64::i64;
    use verdania::pathfinding::utils::map_utils::{convert_position_to_idx, convert_idx_to_position};
    use verdania::constants::MAP_1_ID;

    #[abi(embed_v0)]
    impl PlayerSystem of IPlayerSystem<ContractState> {
        fn create(
            ref self: ContractState, player: ContractAddress, player_name: felt252, gender_id: u64
        ) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let gender: Gender = gender_id.try_into().expect('Cannot convert ID to Gender');

            let player_skin = PlayerSkin { player: player, name: player_name, gender: gender_id };

            store.set_player_skin(player_skin);
        }

        fn equip(ref self: ContractState, player: ContractAddress, item_id: u64) {
            assert(its_a_valid_item(item_id), 'Cannot equip that item');
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let mut player_state = store.get_player_state(player);
            player_state.equipment_item_id = item_id;
            store.set_player_state(player_state);
        }

        fn move(ref self: ContractState, player: ContractAddress, x: u64, y: u64) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);
            let mut player_state = store.get_player_state(player);
            let map = store.get_map(MAP_1_ID);

            assert(
                is_walkable_at(
                    ref store,
                    player_state.farm_id,
                    map,
                    IntegerTrait::<i64>::new(x, false),
                    IntegerTrait::<i64>::new(y, false)
                ),
                'That tile is not walkable'
            );

            player_state.x = x;
            player_state.y = y;
            store.set_player_state(player_state);
        }
    }

    fn is_walkable_at(ref store: Store, farm_id: u64, map: Map, x: i64, y: i64) -> bool {
        if !is_inside(x, y, map.width, map.height) {
            return false;
        }

        let tile_id = convert_position_to_idx(map.width, x.mag, y.mag);
        let tile_state = store.get_tile_state(farm_id, tile_id);
        if tile_state.entity_type == TS_CROP_ID {
            true
        } else if tile_state.entity_type == TS_ENVIROMENT_ID {
            let env_entity_state = store.get_env_entity_state(farm_id, tile_state.entity_index);
            env_entity_state.env_entity_id == ENV_SUITABLE_FOR_CROP
                || env_entity_state.env_entity_id == ENV_ROCK_ID
                || env_entity_state.env_entity_id == ENV_GRASS_ID
        } else {
            let tile = store.get_tile(map.id, tile_id);
            is_walkable(tile)
        }
    }

    fn is_inside(x: i64, y: i64, width: u64, height: u64) -> bool {
        if x.sign || y.sign {
            return false;
        }
        x.mag < width.into() && y.mag < height.into()
    }
}
