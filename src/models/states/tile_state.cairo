use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct TileState {
    #[key]
    farm_id: u64,
    #[key]
    id: u64,
    entity_type: u64,
    entity_index: u64
}
