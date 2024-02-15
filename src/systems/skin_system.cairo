use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait ISkinSystem<TContractState> {
    fn create(ref self: TContractState, player: ContractAddress, player_name: felt252, gender_id: u64);
}

#[dojo::contract]
mod skin_system {
    use super::ISkinSystem;
    use starknet::{get_caller_address, ContractAddress};
    use dojo_starter::store::{Store, StoreTrait};

    #[abi(embed_v0)]
    impl SkinSystem of ISkinSystem<ContractState> {
        fn create(ref self: ContractState, player: ContractAddress, player_name: felt252, gender_id: u64) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);


        }
    }
}
