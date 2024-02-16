use verdania::tests::setup::{setup, setup::Systems, setup::OWNER};
use verdania::store::{Store, StoreTrait};

use starknet::{ContractAddress, get_caller_address, contract_address_const};
use starknet::testing::set_contract_address;
use verdania::constants::MAP_1_ID;
use verdania::systems::map_system::{IMapSystemDispatcher, IMapSystemDispatcherTrait};
use verdania::systems::crop_system::{ICropSystemDispatcher, ICropSystemDispatcherTrait};
use verdania::pathfinding::algorithms::jps_system::{
    IJPSSystemDispatcher, IJPSSystemDispatcherTrait
};
use verdania::systems::farm_system::{IFarmSystemDispatcher, IFarmSystemDispatcherTrait};
use verdania::constants::{tile_state_1, env_entity_state_1};

fn PLAYER() -> ContractAddress {
    contract_address_const::<'PLAYER'>()
}

#[test]
#[available_gas(1000000000000000000)]
fn test_jps_happy_path() {
    // Setup
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // Create a new farm
    systems.farm_system.create_farm(PLAYER());
    let mut farm = store.get_player_farm_state(MAP_1_ID, PLAYER());

    systems.map_system.init();
    systems.crop_system.init();

    let mut farm = store.get_player_farm_state(MAP_1_ID, PLAYER());

    // Crear TileState
    let mut tiles_state = tile_state_1(farm.id);
    loop {
        match tiles_state.pop_front() {
            Option::Some(tile_state) => store.set_tile_state(*tile_state),
            Option::None => { break; }
        }
    };

    // EnvEntityState
    let mut envs_entity_state = env_entity_state_1(farm.id);
    let env_entities_len = envs_entity_state.len();
    loop {
        match envs_entity_state.pop_front() {
            Option::Some(env_entity_state) => store.set_env_entity_state(*env_entity_state),
            Option::None => { break; }
        }
    };

    let goal = (15, 59);
    systems.jps_system.find_path(PLAYER(), goal);
    let path_count = store.get_path_count(PLAYER());

    let player_state = store.get_player_state(PLAYER());
    assert((player_state.x, player_state.y) == goal, 'err player posicion');
}

fn print_span(span: Span<(u64, u64)>) {
    let mut i = 0;
    print!("Span: {{ values: [ ");
    loop {
        if span.len() == i {
            break;
        }
        let (x, y) = *(span.at(i));
        if span.len() - 1 != i {
            print!("(x: {}, y: {}), ", x, y);
        } else {
            print!("(x: {}, y: {})", x, y);
        }
        i += 1;
    };
    println!(" ] }}")
}
