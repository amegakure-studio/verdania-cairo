#[derive(Model, Copy, Drop, Serde)]
struct Interact {
    #[key]
    id_item: u64,
    #[key]
    id_env: u64,
    can_interact: bool
}
