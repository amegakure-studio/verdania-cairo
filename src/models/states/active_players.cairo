use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct ActivePlayers {
    #[key]
    idx: u64,
    player: ContractAddress
}

#[derive(Model, Copy, Drop, Serde)]
struct ActivePlayersLen {
    #[key]
    key: felt252,
    len: u64
}