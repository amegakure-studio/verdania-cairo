use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct MarketplaceMeta {
    #[key]
    token: ContractAddress,
    erc20: ContractAddress,
    erc1155: ContractAddress,
    current_item_len: u256
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