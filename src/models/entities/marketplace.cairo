use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct MarketplaceMeta {
    #[key]
    token: ContractAddress,
    owner: ContractAddress,
    open: bool,
    spawn_time: u64,
    item_list_len: u256
}

#[derive(Model, Copy, Drop, Serde)]
struct MarketplaceItem {
    #[key]
    id: u256,
    seller: ContractAddress,
    amount: u256,
    remaining_amount: u256,
    price: u256
}