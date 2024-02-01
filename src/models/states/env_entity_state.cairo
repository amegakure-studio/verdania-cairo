use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct EnvEntityState {
    #[key]
    farm_id: ContractAddress,
    #[key]
    index: u64,
    entity_id: u64,
    x: u64,
    y: u64,
}
