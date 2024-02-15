use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait ISkinSystem<TContractState> {
    fn create(ref self: TContractState, player: ContractAddress, player_name: felt252, gender_id: u64);
}

#[dojo::contract]
mod skin_system {
    use super::ISkinSystem;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::store::{Store, StoreTrait};
    use verdania::models::entities::skin::{PlayerSkin, Gender};
    
    #[abi(embed_v0)]
    impl SkinSystem of ISkinSystem<ContractState> {
        fn create(ref self: ContractState, player: ContractAddress, player_name: felt252, gender_id: u64) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let gender: Gender = gender_id.try_into().expect('cannot convert id to gender');

            let player_skin = PlayerSkin {
                player: player,
                name: player_name,
                gender: gender_id
            };

            store.set_player_skin(player_skin);
        }
    }
}
