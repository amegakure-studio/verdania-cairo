use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IEnvEntitySystem<TContractState> {
    fn init(ref self: TContractState);
}

#[dojo::contract]
mod env_entity_system {
    use super::IEnvEntitySystem;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::models::entities::env_entity::EnvEntity;
    use verdania::store::{Store, StoreTrait};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl EnvEntitySystem of IEnvEntitySystem<ContractState> {
        fn init(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            store.set_env_entity(EnvEntity {
                id: 1,
                name: 'Tree',
                drop_item_id: 1, // TODO: agregar item id madera
                quantity: 4,
                durability: 2
            });

            store.set_env_entity(EnvEntity {
                id: 2,
                name: 'Trunk',
                drop_item_id: 1, // TODO: agregar item id madera
                quantity: 1,
                durability: 1
            });

            store.set_env_entity(EnvEntity {
                id: 3,
                name: 'Small Rock',
                drop_item_id: 2, // TODO: agregar item id piedra
                quantity: 1,
                durability: 1
            });

            store.set_env_entity(EnvEntity {
                id: 4,
                name: 'Rock',
                drop_item_id: 2, // TODO: agregar item id piedra
                quantity: 4,
                durability: 2
            });
        }
    }
}
