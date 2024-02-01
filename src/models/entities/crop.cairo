#[derive(Model, Copy, Drop, Serde)]
struct Crop {
    #[key]
    id: u64,
    name: felt252,
    harvest_time: u64,
    min_watering_time: u64,
    drop_item_id: u64,
    quantity: u64,
}
// #[derive(Serde, Copy, Drop, PartialEq)]
// enum CropType {
// }

