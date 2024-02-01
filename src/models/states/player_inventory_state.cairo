use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct PlayerInventoryState {
    #[key]
    player: ContractAddress,
    items_len: u64,
    total_slots: u64
}
