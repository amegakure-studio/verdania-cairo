#[derive(Model, Copy, Drop, Serde)]
struct EnvEntity {
    #[key]
    id: u64,
    name: felt252,
    drop_item_id: u64,
    quantity: u64,
}
