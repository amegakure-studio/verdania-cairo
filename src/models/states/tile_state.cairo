use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct TileState {
    #[key]
    farm_id: u64,
    #[key]
    id: u64,
    entity_type: u8,
    entity_index: u64
}

#[derive(Serde, Copy, Drop, PartialEq)]
enum EntityType {
    Enviroment, // 1
    Crop // 2
}
