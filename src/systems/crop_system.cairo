use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait ICropSystem<TContractState> {
    fn init(ref self: TContractState);
}

#[dojo::contract]
mod crop_system {
    use super::ICropSystem;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::models::entities::crop::Crop;
    use verdania::store::{Store, StoreTrait};
    use verdania::models::data::items_id::{PUMPKIN_ID, ONION_ID, CARROT_ID, CORN_ID, MUSHROOM_ID};

    #[abi(embed_v0)]
    impl CropSystem of ICropSystem<ContractState> {
        fn init(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            store
                .set_crop(
                    Crop {
                        id: CORN_ID,
                        name: 'Corn',
                        harvest_time: 259200,
                        min_watering_time: 36000,
                        drop_item_id: CORN_ID,
                        quantity: 3,
                    }
                );

            store
                .set_crop(
                    Crop {
                        id: PUMPKIN_ID,
                        name: 'Pumpkin',
                        harvest_time: 259200,
                        min_watering_time: 36000,
                        drop_item_id: PUMPKIN_ID,
                        quantity: 2,
                    }
                );

            store
                .set_crop(
                    Crop {
                        id: ONION_ID,
                        name: 'Onion',
                        harvest_time: 259200,
                        min_watering_time: 36000,
                        drop_item_id: ONION_ID,
                        quantity: 3,
                    }
                );

            store
                .set_crop(
                    Crop {
                        id: CARROT_ID,
                        name: 'Carrot',
                        harvest_time: 259200,
                        min_watering_time: 36000,
                        drop_item_id: CARROT_ID,
                        quantity: 3,
                    }
                );

            store
                .set_crop(
                    Crop {
                        id: MUSHROOM_ID,
                        name: 'Mushroom',
                        harvest_time: 259200,
                        min_watering_time: 36000,
                        drop_item_id: MUSHROOM_ID,
                        quantity: 2,
                    }
                );
        }
    }
}
