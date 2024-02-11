use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IInteractSystem<TContractState> {
    fn init(ref self: TContractState);
    fn interact(ref self: TContractState, item_id: u64, env_id: u64);
}

#[dojo::contract]
mod interact_system {
    use super::ICropSystem;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::models::entities::crop::Crop;
    use verdania::store::{Store, StoreTrait};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl InteractSystem of IInteractSystem<ContractState> {
        fn init(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);
        }

        fn interact(ref self: TContractState, item_id: u64, env_id: u64) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            if !store.get_interact(item_id, env_id).can_interact {
                return;
            }
        } 
    }
}
