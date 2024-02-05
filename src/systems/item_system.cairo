use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IItemSystem<TContractState> {
    fn init(ref self: TContractState);
}

#[dojo::contract]
mod item_system {
    use super::IItemSystem;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::models::entities::item::Item;
    use verdania::store::{Store, StoreTrait};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl ItemSystem of IItemSystem<ContractState> {
        fn init(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            store.set_item(Item {
                id: 1,
                name: 'Pickaxe',
                env_entity_id: 0 
            });

            store.set_item(Item {
                id: 2,
                name: 'Axe',
                env_entity_id: 0 
            });

            store.set_item(Item {
                id: 3,
                name: 'Hoe',
                env_entity_id: 0 
            });

            store.set_item(Item {
                id: 4,
                name: 'Watering Can',
                env_entity_id: 0 
            });

            store.set_item(Item {
                id: 5,
                name: 'Fish Rot',
                env_entity_id: 0 
            });

            store.set_item(Item {
                id: 6,
                name: 'Pickaxe',
                env_entity_id: 0 
            });

            store.set_item(Item {
                id: 2,
                name: 'Corn kernel',
                env_entity_id: 0 
            });

            store.set_item(Item {
                id: 4,
                name: 'Eggplant seed',
                env_entity_id: 0 
            });

            store.set_item(Item {
                id: 6,
                name: 'Squash seed',
                env_entity_id: 0 
            });

            store.set_item(Item {
                id: 8,
                name: 'Potato tuber',
                env_entity_id: 0 
            });


            store.set_item(Item {
                id: 10,
                name: 'Tomato seed',
                env_entity_id: 0 
            });

            store.set_item(Item {
                id: 12,
                name: 'Onion sedd',
                env_entity_id: 0 
            });
        }
    }
}
