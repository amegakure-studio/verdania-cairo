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
    use verdania::models::data::env_entity_id::{
        ENV_SUITABLE_FOR_CROP, ENV_PUMPKIN_ID, ENV_ONION_ID, ENV_CARROT_ID, ENV_CORN_ID,
        ENV_MUSHROOM_ID, ENV_TREE_ID, ENV_ROCK_ID, ENV_TRUNK_ID, ENV_GRASS_ID
    };
    use verdania::models::data::items_id::{WOOD_ID, ROCK_ID};

    #[abi(embed_v0)]
    impl EnvEntitySystem of IEnvEntitySystem<ContractState> {
        fn init(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            store
                .set_env_entity(
                    EnvEntity {
                        id: ENV_TREE_ID,
                        name: 'Tree',
                        drop_item_id: WOOD_ID,
                        quantity: 4,
                        durability: 3
                    }
                );

            store
                .set_env_entity(
                    EnvEntity {
                        id: ENV_TRUNK_ID,
                        name: 'Trunk',
                        drop_item_id: WOOD_ID,
                        quantity: 1,
                        durability: 1
                    }
                );

            store
                .set_env_entity(
                    EnvEntity {
                        id: ENV_ROCK_ID,
                        name: 'Rock',
                        drop_item_id: ROCK_ID,
                        quantity: 1,
                        durability: 1
                    }
                );

            store
                .set_env_entity(
                    EnvEntity {
                        id: ENV_GRASS_ID,
                        name: 'Grass',
                        drop_item_id: 0,
                        quantity: 0,
                        durability: 0
                    }
                );

            store
                .set_env_entity(
                    EnvEntity {
                        id: ENV_SUITABLE_FOR_CROP,
                        name: 'Suitable for crop',
                        drop_item_id: 0,
                        quantity: 0,
                        durability: 1
                    }
                );
        }
    }
}
