#[derive(Model, Copy, Drop, Serde)]
struct Map {
    #[key]
    id: u64,
    height: u8,
    width: u8
}
