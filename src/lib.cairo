mod models {
    mod data {
        mod game;
        mod world_config;
    }

    mod entities {
        mod crop;
        mod env_entity;
        mod item;
        mod map;
        mod tile;
        mod marketplace;
    }

    mod states {
        mod crop_state;
        mod env_entity_state;
        mod player_farm_state;
        mod player_state;
        mod tile_state;
    }

    mod tokens {
        mod erc20;
        mod erc1155;
    }
}

mod systems {
    mod crop_system;
    mod env_entity_system;
    mod farm_factory_system;
    mod item_system;
    mod map_system;
    mod world_config_system;
    mod erc20_system;
    mod erc1155_system;
    mod marketplace_system;
}

mod interfaces {
    mod IERC20;
    mod IERC1155;
}

#[cfg(test)]
mod tests {
    mod setup;
    mod test_marketplace_system;
}

mod constants;
mod store;
