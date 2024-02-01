#[derive(Model, Copy, Drop, Serde)]
struct Market {
    #[key]
    id: u64,
    open: bool,
    spawn_time: u64,
    item_listed_len: u64
}
