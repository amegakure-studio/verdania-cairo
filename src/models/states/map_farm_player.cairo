use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct MapFarmPlayer {
    #[key]
    farm_id: u64,
    owner: ContractAddress,
}
