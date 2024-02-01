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
    use verdania::store::{Store, StoreTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl MapSystem of IMapSystem<ContractState> {
         fn init(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let beach_farm = Map { id: 1, height: 60, width: 30 };

            // generate tiles
            let (mut x, mut y) = (0, 0);
            loop {
                if y == beach_farm.height {
                    break;
                }

                if x == beach_farm.width {
                    x = 0;
                    y += 1;
                }
                store
                    .set_tile(
                        Tile {
                            map_id: beach_farm.id, id: y * beach_farm.width + x, x, y, tile_type: 1
                        }
                    );
            };
            store.set_map(beach_farm);
        }
    }
}
