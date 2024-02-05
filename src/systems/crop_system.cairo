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

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl CropSystem of ICropSystem<ContractState> {
        fn init(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            store.set_crop(Crop {
                id: 1,
                name: 'Corn',
                harvest_time: 1000,
                min_watering_time: 200,
                drop_item_id: 1,
                quantity: 1,
            });

            store.set_crop(Crop {
                id: 2,
                name: 'Eggplant',
                harvest_time: 1000,
                min_watering_time: 200,
                drop_item_id: 1,
                quantity: 1,
            });

            store.set_crop(Crop {
                id: 3,
                name: 'Squash',
                harvest_time: 1000,
                min_watering_time: 200,
                drop_item_id: 1,
                quantity: 1,
            });

            store.set_crop(Crop {
                id: 4,
                name: 'Potato',
                harvest_time: 1000,
                min_watering_time: 200,
                drop_item_id: 1,
                quantity: 1,
            });

            store.set_crop(Crop {
                id: 5,
                name: 'Tomato',
                harvest_time: 1000,
                min_watering_time: 200,
                drop_item_id: 1,
                quantity: 1,
            });

            store.set_crop(Crop {
                id: 6,
                name: 'Onion',
                harvest_time: 1000,
                min_watering_time: 200,
                drop_item_id: 1,
                quantity: 1,
            });
        }
    }
}
