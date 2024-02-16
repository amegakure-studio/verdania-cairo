use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct CropState {
    #[key]
    farm_id: u64,
    #[key]
    index: u64,
    crop_id: u64,
    x: u64,
    y: u64,
    growing_progress: u64,
    planting_time: u64,
    last_watering_time: u64,
    watered: bool,
    harvested: bool,
}
