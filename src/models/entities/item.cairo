#[derive(Model, Copy, Drop, Serde)]
struct Item {
    #[key]
    id: u64,
    name: felt252,
    env_entity_id: u64
}
