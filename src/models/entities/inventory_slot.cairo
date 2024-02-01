use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct InventorySlot {
    #[key]
    player: ContractAddress,
    #[key]
    index: u64,
    item_id: u64,
    quantity: u64
}
