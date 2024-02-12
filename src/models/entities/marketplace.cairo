use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct MarketplaceMeta {
    #[key]
    id: felt252,
    owner: ContractAddress,
    open: bool,
    spawn_time: u64,
    item_list_len: u256
}

#[derive(Model, Copy, Drop, Serde)]
struct MarketplaceItem {
    #[key]
    id: u256,
    token_id: u256,
    seller: ContractAddress,
    amount: u256,
    remaining_amount: u256,
    price: u256
}
