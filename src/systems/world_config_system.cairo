use verdania::models::data::world_config::GlobalContract;

#[starknet::interface]
trait IWorldConfigSystem<TContractState> {
    fn init_global_contracts(ref self: TContractState, global_contracts: Span<GlobalContract>);
}

#[dojo::contract]
mod world_config_system {
    use super::IWorldConfigSystem;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::models::data::world_config::GlobalContract;
    use verdania::store::{Store, StoreTrait};

    #[abi(embed_v0)]
    impl WorldConfigSystem of IWorldConfigSystem<ContractState> {
        fn init_global_contracts(ref self: ContractState, global_contracts: Span<GlobalContract>) {
            let mut global_contracts = global_contracts;
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);
            loop {
                match global_contracts.pop_front() {
                    Option::Some(global_contract) => store.set_global_contract(*global_contract), 
                    Option::None => { break; }
                }
            };
        }
    }
}
