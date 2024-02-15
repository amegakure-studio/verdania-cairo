use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct WorldConfig {
    #[key]
    id: u64,
    weather: u8,
    sync_time: u64,
    max_players_per_farm: u8,
    active_players_len: u64,
    max_time_unactivity: u64,
    market_close_time: u64,
    market_open_time: u64,
}

#[derive(Model, Copy, Drop, Serde)]
struct GlobalContract {
    #[key]
    id: felt252,
    address: ContractAddress
}
