#[derive(Model, Copy, Drop, Serde)]
struct Crop {
    #[key]
    id: u64,
    crop_type: u8,
    harvest_time: u64,
    min_watering_time: u64,
    env_entity_id: u64,
}

// #[derive(Serde, Copy, Drop, PartialEq)]
// enum CropType {
// }
