use verdania::interfaces::IERC1155::IERC1155DispatcherTrait;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use verdania::constants::MAP_1_ID;
use verdania::models::states::{
    tile_state::TileState, crop_state::CropState, env_entity_state::EnvEntityState
};
use verdania::models::entities::interact::Interact;
use verdania::models::entities::env_entity::{EnvEntity};
use verdania::models::data::items_id::{PUMPKIN_ID, PUMPKIN_SEED_ID};
use verdania::models::data::env_entity_id::{
    ENV_SUITABLE_FOR_CROP, ENV_PUMPKIN_ID, ENV_ONION_ID, ENV_CARROT_ID, ENV_CORN_ID,
    ENV_MUSHROOM_ID, ENV_TREE_ID, ENV_ROCK_ID
};
use verdania::models::states::tile_state::{TS_ENVIROMENT_ID, TS_CROP_ID};
use verdania::tests::setup::{setup, setup::Systems, setup::OWNER};
use verdania::store::{Store, StoreTrait};
use verdania::systems::farm_system::{IFarmSystemDispatcher, IFarmSystemDispatcherTrait};
use verdania::systems::interact_system::{IInteractSystemDispatcher, IInteractSystemDispatcherTrait};
use verdania::systems::map_system::{IMapSystemDispatcher, IMapSystemDispatcherTrait};
use verdania::systems::crop_system::{ICropSystemDispatcher, ICropSystemDispatcherTrait};
use verdania::systems::env_entity_system::{
    IEnvEntitySystemDispatcher, IEnvEntitySystemDispatcherTrait
};

use starknet::{ContractAddress, get_caller_address, contract_address_const};
use starknet::testing::set_contract_address;

fn PLAYER() -> ContractAddress {
    contract_address_const::<'PLAYER'>()
}

#[test]
#[available_gas(1_000_000_000_000)]
#[should_panic(expected: ('player must be adjacent to grid', 'ENTRYPOINT_FAILED'))]
fn test_interact_non_adjacent() {
    // Setup
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // Create a new farm
    systems.farm_system.create_farm(PLAYER());
    let farm = store.get_player_farm_state(MAP_1_ID, PLAYER());

    systems.map_system.init();

    // Set player position
    let mut player_state = store.get_player_state(PLAYER());
    player_state.x = 27;
    player_state.y = 13;
    store.set_player_state(player_state);

    // Create a crop into (29, 13) 
    let map = store.get_map(MAP_1_ID);
    let crop_state = CropState {
        farm_id: 1,
        index: 1,
        crop_id: 1,
        x: 29,
        y: 13,
        growing_progress: 0,
        planting_time: 0,
        last_watering_time: 0,
        harvested: false,
    };

    let tile_state = TileState {
        farm_id: 1, id: (13 * map.width) + 29, entity_type: 2, entity_index: 1,
    };

    store.set_tile_state(tile_state);
    store.set_crop_state(crop_state);

    systems.interact_system.interact(PLAYER(), (13 * map.width) + 29);
}

#[test]
#[available_gas(1_000_000_000_000)]
fn test_interact_its_a_crop_ready_to_be_harvest() {
    // Setup
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // Create a new farm
    systems.farm_system.create_farm(PLAYER());
    let mut farm = store.get_player_farm_state(MAP_1_ID, PLAYER());

    systems.map_system.init();
    systems.crop_system.init();

    let map = store.get_map(MAP_1_ID);

    let x = 28;
    let y = 13;
    let interact_grid_id = (y * map.width) + (x - 1);

    // Set player position
    let mut player_state = store.get_player_state(PLAYER());
    player_state.x = x;
    player_state.y = y;
    store.set_player_state(player_state);

    let tile_state = TileState {
        farm_id: farm.id, id: interact_grid_id, entity_type: TS_CROP_ID, entity_index: 1000,
    };

    let env_entity_state = EnvEntityState {
        farm_id: farm.id, index: 1000, env_entity_id: ENV_PUMPKIN_ID, x: x - 1, y: y, active: true,
    };

    // Create a crop into (29, 13) 
    let crop_state = CropState {
        farm_id: farm.id,
        index: 1000,
        crop_id: PUMPKIN_ID,
        x: x - 1,
        y: y,
        growing_progress: 100,
        planting_time: 0,
        last_watering_time: 0,
        harvested: false,
    };
    farm.crops_len += 1;

    store.set_player_farm_state(farm);
    store.set_tile_state(tile_state);
    store.set_crop_state(crop_state);

    let pumpkin_quantity_bf = systems.erc1155_system.balance_of(PLAYER(), PUMPKIN_ID.into());

    systems.interact_system.interact(PLAYER(), interact_grid_id);

    // check player gets the tokens
    let pumpkin_quantity = systems.erc1155_system.balance_of(PLAYER(), PUMPKIN_ID.into());
    assert(pumpkin_quantity == pumpkin_quantity_bf + 2, 'wrong pumpkin amount');

    // check the tile its free now
    let new_ts = store.get_tile_state(farm.id, interact_grid_id);
    assert(new_ts.entity_type.is_zero(), 'entity type should be zero');
    assert(new_ts.entity_index.is_zero(), 'entity index should be zero');
}
// #[test]
// #[available_gas(1_000_000_000_000)]
// fn test_interact_equipment_is_a_seed_and_tile_is_suitable_for_crop() {
//     // Setup
//     let (world, systems) = setup::spawn_game();
//     let mut store = StoreTrait::new(world);

//     // Create a new farm
//     systems.farm_system.create_farm(PLAYER());
//     let mut farm = store.get_player_farm_state(MAP_1_ID, PLAYER());

//     // Init systems
//     systems.map_system.init();
//     systems.env_entity_system.init();
//     systems.crop_system.init();

//     let map = store.get_map(MAP_1_ID);

//     let x = 28;
//     let y = 13;
//     let interact_grid_id = (y * map.width) + (x - 1);

//     // Set player position with a corn seed equiped
//     let mut player_state = store.get_player_state(PLAYER());
//     player_state.equipment_item_id = PUMPKIN_SEED_ID;
//     player_state.x = x;
//     player_state.y = y;
//     store.set_player_state(player_state);

//     // check corn seed balance
//     let corn_seed_quantity_bf = systems.erc1155_system.balance_of(PLAYER(), PUMPKIN_SEED_ID.into()); 

//     store.set_player_farm_state(farm);

//     // Set tile suitable for crop into (x: 29, y: 13) 
//     let tile_state = TileState {
//         farm_id: farm.id,
//         id: interact_grid_id,
//         entity_type: TS_ENVIROMENT_ID, 
//         entity_index: 1000,
//     };

//     let env_entity_state = EnvEntityState {
//         farm_id: farm.id,
//         index: 1000,
//         env_entity_id: ENV_SUITABLE_FOR_CROP,
//         x: x - 1,
//         y: y,
//         active: true,
//     };

//     store.set_env_entity_state(env_entity_state);
//     store.set_tile_state(tile_state);
//     systems.interact_system.interact(PLAYER(), interact_grid_id);

//     let corn_seed_quantity_af = systems.erc1155_system.balance_of(PLAYER(), PUMPKIN_SEED_ID.into()); 
//     assert(corn_seed_quantity_bf == corn_seed_quantity_af + 1, 'wrong seed quantity');

//     // check that tile_state change to ENV_PUMPKIN_ID and CROP its placed on that tile
//     let tile_state_af = store.get_tile_state(farm.id, interact_grid_id);
//     assert(tile_state_af.entity_type == TS_CROP_ID, 'entity type != TS_CROP_ID');
//     assert(tile_state_af.entity_index == 1000, 'wrong entity index');
//     assert(tile_state_af.id == interact_grid_id, 'wrong tile grid_id');

//     let env_entity_state_af = store.get_env_entity_state(farm.id, 1000);
//     assert(env_entity_state_af.env_entity_id == ENV_PUMPKIN_ID, 'wrong env entity id');
//     assert(env_entity_state_af.x == (x - 1), 'wrong env entity x');
//     assert(env_entity_state_af.y == y, 'wrong env entity y');
// }


