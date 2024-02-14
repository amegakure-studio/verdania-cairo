use verdania::interfaces::IERC1155::IERC1155DispatcherTrait;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use verdania::constants::MAP_1_ID;
use verdania::models::states::{tile_state::TileState, crop_state::CropState};
use verdania::models::entities::interact::Interact;
use verdania::models::data::items_id::{CORN_ID, CORN_SEED_ID};
use verdania::tests::setup::{setup, setup::Systems, setup::OWNER};
use verdania::store::{Store, StoreTrait};
use verdania::systems::farm_factory_system::{
    IFarmFactorySystemDispatcher, IFarmFactorySystemDispatcherTrait
};
use verdania::systems::interact_system::{
    IInteractSystemDispatcher, IInteractSystemDispatcherTrait
};
use verdania::systems::map_system::{
    IMapSystemDispatcher, IMapSystemDispatcherTrait
};

use starknet::{ContractAddress, get_caller_address, contract_address_const};
use starknet::testing::set_contract_address;

fn PLAYER() -> ContractAddress {
    contract_address_const::<'PLAYER'>()
}

// #[test]
// #[available_gas(1_000_000_000_000)]
// #[should_panic(expected: ('player must be adjacent to grid', 'ENTRYPOINT_FAILED'))]
// fn test_interact_non_adjacent() {
//     // Setup
//     let (world, systems) = setup::spawn_game();
//     let mut store = StoreTrait::new(world);

//     // Create a new farm
//     systems.farm_factory_system.create_farm(PLAYER());
//     let farm = store.get_player_farm_state(MAP_1_ID, PLAYER());
    
//     systems.map_system.init();
    
//     // Set player position
//     let mut player_state = store.get_player_state(PLAYER());
//     player_state.x = 27;
//     player_state.y = 13;
//     store.set_player_state(player_state);

//     // Create a crop into (29, 13) 
//     let map = store.get_map(MAP_1_ID);
//     let crop_state = CropState {
//         farm_id: 1,
//         index: 1,
//         crop_id: 1,
//         x: 29,
//         y: 13,
//         growing_progress: 0,
//         planting_time: 0,
//         last_watering_time: 0,
//         harvested: false,
//     };

//     let tile_state = TileState {
//         farm_id: 1,
//         id: (13 * map.width) + 29,
//         entity_type: 2,
//         entity_index: 1,
//     };

//     store.set_tile_state(tile_state);
//     store.set_crop_state(crop_state);

//     systems.interact_system.interact(PLAYER(), (13 * map.width) + 29);
// }

#[test]
#[available_gas(1_000_000_000_000)]
fn test_interact_its_a_crop_ready_to_be_harvest() {
    // Setup
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // Create a new farm
    systems.farm_factory_system.create_farm(PLAYER());
    let mut farm = store.get_player_farm_state(MAP_1_ID, PLAYER());
    
    systems.map_system.init();
    
    // Set player position
    let mut player_state = store.get_player_state(PLAYER());
    player_state.x = 28;
    player_state.y = 13;
    store.set_player_state(player_state);

    // Create a crop into (29, 13) 
    let map = store.get_map(MAP_1_ID);
    let crop_state = CropState {
        farm_id: 1,
        index: 1,
        crop_id: CORN_ID,
        x: 29,
        y: 13,
        growing_progress: 100,
        planting_time: 0,
        last_watering_time: 0,
        harvested: false,
    };
    farm.crops_len += 1;
    store.set_player_farm_state(farm);

    let tile_state = TileState {
        farm_id: 1,
        id: (13 * map.width) + 29,
        entity_type: 2,
        entity_index: 1,
    };

    store.set_tile_state(tile_state);
    store.set_crop_state(crop_state);

    systems.interact_system.interact(PLAYER(), (13 * map.width) + 29);

    // check player gets the tokens
    let corn_balance = systems.erc1155_system.balance_of(PLAYER(), CORN_ID.into());
    assert(corn_balance == 3, 'wrong corn amount');
    // check the tile its free now
}
