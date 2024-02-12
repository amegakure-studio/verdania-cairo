const FARM_COUNT_KEY: felt252 = 'farm_idx_key';

#[derive(Model, Copy, Drop, Serde)]
struct FarmCount {
    #[key]
    id: felt252,
    index: u64,
}
