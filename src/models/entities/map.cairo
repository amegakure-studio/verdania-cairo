#[derive(Model, Copy, Drop, Serde)]
struct Map {
    #[key]
    id: u64,
    height: u64,
    width: u64
}
