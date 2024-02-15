use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct MarketplaceMeta {
    #[key]
    id: felt252,
    owner: ContractAddress,
    open: bool,
    spawn_time: u64,
    item_list_len: u64
}

#[derive(Model, Copy, Drop, Serde)]
struct MarketplaceItem {
    #[key]
    id: u64,
    token_id: u64,
    seller: ContractAddress,
    amount: u64,
    remaining_amount: u64,
    price: u64
}
