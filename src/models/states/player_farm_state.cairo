use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct PlayerFarmState {
    #[key]
    map_id: u64,
    #[key]
    player: ContractAddress,
    farm_id: u64,
    name: felt252,
    crops_len: u64,
    env_entities_len: u64,
    connected_players: u64,
    open: bool,
    invitation_code: felt252
}
