use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct EnvEntityState {
    #[key]
    farm_id: u64,
    #[key]
    index: u64,
    env_entity_id: u64,
    x: u64,
    y: u64,
}
