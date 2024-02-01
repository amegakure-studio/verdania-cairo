#[derive(Model, Copy, Drop, Serde)]
struct MarketListed {
    #[key]
    marked_id: u64,
    index: u64,
    item_id: u64,
    quantity: u64,
    price: u256
}
