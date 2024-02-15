use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct PlayerState {
    #[key]
    player: ContractAddress,
    farm_id: u64,
    x: u64,
    y: u64,
    equipment_item_id: u64,
    tokens: u64,
}
