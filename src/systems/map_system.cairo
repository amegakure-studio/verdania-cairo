use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IMapSystem<TContractState> {
    fn init(ref self: TContractState);
}

#[dojo::contract]
mod map_system {
    use super::IMapSystem;
    use starknet::{get_caller_address, ContractAddress};
    use verdania::models::entities::map::Map;
    use verdania::models::entities::tile::Tile;
    use verdania::constants::map_1;
    use verdania::store::{Store, StoreTrait};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl MapSystem of IMapSystem<ContractState> {
        fn init(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let (mut tiles, height, width) = map_1();
            loop {
                match tiles.pop_front() {
                    Option::Some(tile) => store.set_tile(*tile),
                    Option::None => { break; }
                }
            };

            let beach_farm = Map { id: 1, height, width };
            store.set_map(beach_farm);
        }
    }
}
