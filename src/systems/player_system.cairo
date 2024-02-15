use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IPlayerSystem<TContractState> {
    fn create(ref self: TContractState, player: ContractAddress, player_name: felt252, gender_id: u64);
    fn equip(ref self: TContractState, player: ContractAddress, item_id: u64);
}

#[dojo::contract]
mod player_system {
    use super::IPlayerSystem;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::store::{Store, StoreTrait};
    use verdania::models::entities::skin::{PlayerSkin, Gender};
    use verdania::models::entities::item::{Item, Tool, its_a_valid_item};

    #[abi(embed_v0)]
    impl PlayerSystem of IPlayerSystem<ContractState> {
        fn create(ref self: ContractState, player: ContractAddress, player_name: felt252, gender_id: u64) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let gender: Gender = gender_id.try_into().expect('Cannot convert ID to Gender');

            let player_skin = PlayerSkin {
                player: player,
                name: player_name,
                gender: gender_id
            };

            store.set_player_skin(player_skin);
        }

        fn equip(ref self: ContractState, player: ContractAddress, item_id: u64) {
            assert(its_a_valid_item(item_id), 'Cannot equip that item');
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let mut player_state = store.get_player_state(player);
            player_state.equipment_item_id = item_id;
            store.set_player_state(player_state);
        }
    }
}
