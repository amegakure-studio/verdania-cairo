// Starknet imports

use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct ERC1155Meta {
    #[key]
    id: felt252,
    owner: ContractAddress
// name: felt252,
// symbol: felt252,
// base_uri: felt252,
}

#[derive(Model, Copy, Drop, Serde)]
struct ERC1155OperatorApproval {
    #[key]
    id: felt252,
    #[key]
    owner: ContractAddress,
    #[key]
    operator: ContractAddress,
    approved: bool
}


#[derive(Model, Copy, Drop, Serde)]
struct ERC1155Balance {
    #[key]
    id_contract: felt252,
    #[key]
    account: ContractAddress,
    #[key]
    id: u64,
    amount: u64
}
