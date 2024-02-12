use verdania::models::data::world_config::GlobalContract;
use verdania::store::{Store, StoreTrait};

use starknet::ContractAddress;

#[starknet::interface]
trait ICropStateUpdaterSystem<TContractState> {
    fn sync(ref self: TContractState);
    fn player_connected(ref self: TContractState, player: ContractAddress);
    // TODO: make update_crops_states internal
    fn update_crops_states(ref self: TContractState, player_id: ContractAddress);
}

#[dojo::contract]
mod world_config_system {
    use core::array::SpanTrait;
    use core::array::ArrayTrait;
    use super::{ICropStateUpdaterSystem};
    use starknet::{get_caller_address, ContractAddress};
    use verdania::models::data::world_config::GlobalContract;
    use verdania::models::states::active_players::{ActivePlayers, ActivePlayersLen};
    use verdania::constants::ACTIVE_PLAYERS_LEN_ID;
    use verdania::store::{Store, StoreTrait};
    use verdania::constants::MAP_1_ID;

    const AFK_TIMEOUT: u64 = 600; // 10 min

    #[abi(embed_v0)]
    impl CropStateUpdaterSystem of ICropStateUpdaterSystem<ContractState> {
        fn player_connected(ref self: ContractState, player: ContractAddress) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);
            let active_players_len = store.get_active_players_len();

            store.set_active_player(ActivePlayers { idx: active_players_len.len + 1, player: player });
            store.set_active_players_len(ActivePlayersLen { key: ACTIVE_PLAYERS_LEN_ID, len: active_players_len.len + 1 });

            self.update_crops_states(player)
        }

        fn sync(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let mut new_active_players_len = 0;
            let actual_timestamp = starknet::get_block_timestamp();
            let mut active_players = store.get_verdania_active_players(); 
            loop {
                if active_players.is_empty() {
                    break;
                }   
                let player_id = *(active_players.pop_front().unwrap()).player;
                let player_state = store.get_player_state(player_id); 
                
                if player_state.last_timestamp_activity + AFK_TIMEOUT < actual_timestamp {
                    store.set_active_player(ActivePlayers { idx: new_active_players_len, player: player_id });
                    new_active_players_len += 1;
                    self.update_crops_states(player_id);
                } 
            };
            store.set_active_players_len(ActivePlayersLen { key: ACTIVE_PLAYERS_LEN_ID, len: new_active_players_len });
        }

        fn update_crops_states(ref self: ContractState, player_id: ContractAddress) {
             // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);
            let actual_timestamp = starknet::get_block_timestamp();
            
            let farm = store.get_player_farm_state(MAP_1_ID, player_id);
            let mut farm_crop_states = store.get_crops_states(player_id, farm.farm_id); 
            let mut new_farm_crops_len = 0; 
            loop {
                if farm_crop_states.is_empty() {
                    break;
                }
                let mut crop_state = *(farm_crop_states.pop_front().unwrap());
                let crop_info = store.get_crop(crop_state.crop_id);

                // if crop its dead, we should update tile state
                if crop_state.last_watering_time + crop_info.min_watering_time < actual_timestamp {
                    let map = store.get_map(MAP_1_ID);
                    
                    let mut tile_state = store.get_tile_state(farm.farm_id, (map.width * crop_state.y) + crop_state.x);
                    tile_state.entity_index = 0;
                    tile_state.entity_type = 0;
                    store.set_tile_state(tile_state);
                } else {
                    let mut growing_percentage = (actual_timestamp * 100) / crop_info.harvest_time;
                    if growing_percentage >= 100 {
                        growing_percentage = 100;                                
                    }

                    crop_state.index = new_farm_crops_len;
                    crop_state.growing_progress = growing_percentage;
                    
                    store.set_crop_state(crop_state);
                    new_farm_crops_len += 1;
                }
            }
        }
    }
}
