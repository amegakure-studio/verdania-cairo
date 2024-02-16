use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct PathCount {
    #[key]
    player: ContractAddress,
    index: u32,
    last_update: u64,
}

#[derive(Model, Copy, Drop, Serde)]
struct Path {
    #[key]
    player: ContractAddress,
    #[key]
    id: u64,
    x: u64,
    y: u64,
}
