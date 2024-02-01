use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IFarmFactorySystem<TContractState> {
    fn create_farm(ref self: TContractState, player: felt252);
}

#[dojo::contract]
mod farm_factory_system {
    use super::IFarmFactorySystem;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::models::entities::crop::Crop;
    use verdania::store::{Store, StoreTrait};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl FarmFactory of IFarmFactorySystem<ContractState> {
        fn create_farm(ref self: ContractState, player: felt252) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);


            // Crear solo la primera vez

            // Crear TileState
            // Crear EnvEntity
            // Crear CropState
            
            // Crear PlayerFarmState
            
            // Crear PlayerState 
            // Crear AccountPlayerState 
            
        }
    }
}
