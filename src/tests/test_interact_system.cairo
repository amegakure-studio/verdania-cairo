// Core imports
use debug::PrintTrait;

// Dojo imports
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports
use verdania::store::{Store, StoreTrait};

use starknet::{ContractAddress, get_caller_address, contract_address_const};
use starknet::testing::set_contract_address;
use integer::BoundedInt;

use verdania::tests::setup::{setup, setup::Systems, setup::OWNER};

fn CALLER_USER() -> ContractAddress {
    contract_address_const::<'USER'>()
}

#[test]
#[available_gas(1_000_000_000)]
fn test_interact_non_adjacent() {
    // Setup
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // mint ERC1155 to ASSET_OWNER
    set_contract_address(OWNER());
    let token_id = 99;
    let amount = 10;
    systems.erc1155_system.mint(CALLER_ASSET_OWNER(), token_id, amount);

    // list item of ASSET_OWNER
    let price = 20;
    let item_id = systems
        .marketplace_system
        .list_item(CALLER_ASSET_OWNER().into(), token_id, amount, price);

    // check item
    let item = store.get_marketplace_item(item_id);
    assert(item.seller == CALLER_ASSET_OWNER(), 'wrong seller');
    assert(item.id == 0, 'wrong token_id');
    assert(item.amount == amount, 'wrong amount');
    assert(item.remaining_amount == amount, 'wrong remaining_amount');
    assert(item.price == price, 'wrong price');

    // check balance ERC1155
    assert(
        systems.erc1155_system.balance_of(CALLER_ASSET_OWNER(), token_id) == 0,
        'balance asset owner'
    );
    assert(
        systems
            .erc1155_system
            .balance_of(systems.marketplace_system.contract_address, token_id) == amount,
        'balance marketplace'
    );
}

#[test]
#[available_gas(1_000_000_000)]
fn test_buy_item() {
    // Setup
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);
}
