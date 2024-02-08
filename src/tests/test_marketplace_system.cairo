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
use verdania::interfaces::IERC1155::{IERC1155Dispatcher, IERC1155DispatcherTrait};
use verdania::interfaces::IERC20::{IERC20Dispatcher, IERC20DispatcherTrait};
use verdania::systems::marketplace_system::{IMarketplaceDispatcher, IMarketplaceDispatcherTrait};
use verdania::models::entities::marketplace::{MarketplaceMeta, MarketplaceItem};

// Constants
const ACCOUNT: felt252 = 'ACCOUNT';
const SEED: felt252 = 'SEED';
const NAME: felt252 = 'NAME';

fn CALLER_ASSET_OWNER() -> ContractAddress {
    contract_address_const::<'ASSET_OWNER'>()
}

fn CALLER_USER() -> ContractAddress {
    contract_address_const::<'USER'>()
}

#[test]
#[available_gas(1_000_000_000)]
fn test_list_item() {
    // Setup
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // mint ERC1155 to ASSET_OWNER
    set_contract_address(OWNER());
    let token_id = 99;
    let amount = 10;
    systems.erc1155_system.mint(CALLER_ASSET_OWNER(), token_id, amount);

    // set approve ASSET_OWNER to Marketplace
    set_contract_address(CALLER_ASSET_OWNER());
    systems.erc1155_system.set_approval_for_all(systems.marketplace_system.contract_address, true);

    // list item of ASSET_OWNER
    let price = 20;
    let item_id = systems.marketplace_system.list_item(token_id, amount, price);

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
        systems.erc1155_system.balance_of(systems.marketplace_system.contract_address, token_id) == amount,
        'balance marketplace'
    );
}

#[test]
#[available_gas(1_000_000_000)]
fn test_buy_item() {
    // Setup
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // mint ERC1155 to ASSET_OWNER
    set_contract_address(OWNER());
    let token_id = 99;
    let amount = 10;
    systems.erc1155_system.mint(CALLER_ASSET_OWNER(), token_id, amount);

    // mint ERC20 to USER
    let tokens_caller_user = 500;
    systems.erc20_system.mint(CALLER_USER(), tokens_caller_user);
    
    // set approve ASSET_OWNER to Marketplace
    set_contract_address(CALLER_ASSET_OWNER());
    systems.erc1155_system.set_approval_for_all(systems.marketplace_system.contract_address, true);
    
    // set approve USER to Marketplace
    set_contract_address(CALLER_USER());
    systems.erc20_system.approve(systems.marketplace_system.contract_address, tokens_caller_user);

    // list item of ASSET_OWNER
    set_contract_address(CALLER_ASSET_OWNER());
    let price = 20;
    let item_id = systems.marketplace_system.list_item(token_id, amount, price);

    // USER buy item of ASSET_OWNER
    set_contract_address(CALLER_USER());
    let amount_token = 5;
    systems.marketplace_system.buy_item(item_id, amount_token);

    // check item
    let item = store.get_marketplace_item(item_id);
    assert(
        item.remaining_amount == amount - amount_token, 'wrong remaining_amount'
    );

    // check balance ERC1155
    assert(
        systems.erc1155_system.balance_of(CALLER_USER(), token_id) == amount_token,
        'wrong caller_user'
    );
    assert(
        systems.erc1155_system
            .balance_of(
                systems.marketplace_system.contract_address, token_id
            ) == amount
            - amount_token,
        'wrong marketplace'
    );

    // check balance ERC20
    let total_price = amount_token * price;
    assert(
        systems.erc20_system.balance_of(CALLER_USER()) == tokens_caller_user - total_price,
        'wrong erc20 user'
    );
    assert(
        systems.erc20_system.balance_of(CALLER_ASSET_OWNER()) == total_price,
        'wrong erc20 asset owner '
    );
}
