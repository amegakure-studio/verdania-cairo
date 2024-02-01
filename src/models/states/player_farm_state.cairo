use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct PlayerFarmState {
    #[key]
    player: ContractAddress,
    #[key]
    map_id: u64,
    farm_id: u64,
    name: felt252,
    crops_len: u64,
    entities_len: u64,
    connected_players: u64,
    open: bool,
    invitation_code: felt252
}
