// Starknet imports

use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct ERC20Balance {
    #[key]
    id: felt252,
    #[key]
    account: ContractAddress,
    amount: u256,
}

#[derive(Model, Copy, Drop, Serde)]
struct ERC20Allowance {
    #[key]
    id: felt252,
    #[key]
    owner: ContractAddress,
    #[key]
    spender: ContractAddress,
    amount: u256,
}

#[derive(Model, Copy, Drop, Serde)]
struct ERC20Meta {
    #[key]
    id: felt252,
    name: felt252,
    symbol: felt252,
    total_supply: u256,
    owner: ContractAddress
}
