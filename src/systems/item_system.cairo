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
    use verdania::models::data::items_id::{
        PICKAXE_ID, HOE_ID, WATERING_CAN_ID, PUMPKIN_SEED_ID, ONION_SEED_ID, CARROT_SEED_ID,
        CORN_SEED_ID, MUSHROOM_SEED_ID, PUMPKIN_ID, ONION_ID, CARROT_ID, CORN_ID, MUSHROOM_ID
    };
    use verdania::models::data::env_entity_id::{
        ENV_PUMPKIN_ID, ENV_ONION_ID, ENV_CARROT_ID, ENV_CORN_ID, ENV_MUSHROOM_ID
    };

    #[abi(embed_v0)]
    impl ItemSystem of IItemSystem<ContractState> {
        fn init(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            // store.set_item(Item { id: PICKAXE_ID, name: 'Pickaxe', env_entity_id: 0 });

            store.set_item(Item { id: HOE_ID, name: 'Hoe', env_entity_id: 0 });

            store.set_item(Item { id: WATERING_CAN_ID, name: 'Watering Can', env_entity_id: 0 });

            store.set_item(Item { id: PUMPKIN_ID, name: 'Pumpkin', env_entity_id: 0 });

            store.set_item(Item { id: ONION_ID, name: 'Onion', env_entity_id: 0 });

            store.set_item(Item { id: CARROT_ID, name: 'Carrot', env_entity_id: 0 });

            store.set_item(Item { id: CORN_ID, name: 'Corn', env_entity_id: 0 });

            store.set_item(Item { id: MUSHROOM_ID, name: 'Mushroom', env_entity_id: 0 });

            store
                .set_item(
                    Item {
                        id: PUMPKIN_SEED_ID, name: 'Pumpkin Seed', env_entity_id: ENV_PUMPKIN_ID
                    }
                );

            store
                .set_item(
                    Item { id: ONION_SEED_ID, name: 'Onion Seed', env_entity_id: ENV_ONION_ID }
                );

            store
                .set_item(
                    Item { id: CARROT_SEED_ID, name: 'Carrot Seed', env_entity_id: ENV_CARROT_ID }
                );

            store.set_item(Item { id: CORN_ID, name: 'Corn Seed', env_entity_id: ENV_CORN_ID });

            store
                .set_item(
                    Item { id: MUSHROOM_ID, name: 'Mushroom Seed', env_entity_id: ENV_MUSHROOM_ID }
                );
        }
    }
}
