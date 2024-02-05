mod models {
    mod data {
        mod game;
        mod world_config;
    }

    mod entities {
        mod crop;
        mod env_entity;
        mod inventory_slot;
        mod item;
        mod map;
        mod market_listed;
        mod market;
        mod tile;
    }

    mod states {
        mod crop_state;
        mod env_entity_state;
        mod player_farm_state;
        mod player_inventory_state;
        mod player_state;
        mod tile_state;
    }
}

mod systems {
    mod crop_system;
    mod env_entity_system;
    mod farm_factory_system;
    mod item_system;
    mod map_system;
}

mod tests { // mod test_world;
}

mod marketplace {
    mod erc20 {
        mod erc20;
        mod interface;
        mod models;
    }
    mod erc1155 {
        mod erc1155;
        mod interface;
        mod models;
    }
}

mod constants;
mod store;
