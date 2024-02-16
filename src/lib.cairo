mod models {
    mod data {
        mod env_entity_id;
        mod items_id;
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
        mod skin;
        mod interact;
    }

    mod states {
        mod crop_state;
        mod env_entity_state;
        mod player_farm_state;
        mod player_state;
        mod tile_state;
        mod active_players;
    }

    mod tokens {
        mod erc20;
        mod erc1155;
    }
}

mod systems {
    // mod action_system;
    mod crop_system;
    mod env_entity_system;
    mod farm_system;
    mod item_system;
    mod map_system;
    mod world_config_system;
    mod erc20_system;
    mod erc1155_system;
    mod marketplace_system;
    mod interact_system;
    mod updater_system;
    mod player_system;
}

mod interfaces {
    mod IERC20;
    mod IERC1155;
}

mod pathfinding {
    mod algorithms {
        mod jps_system;
    }

    mod data_structures {
        mod tile_info;
        mod min_heap;
        mod path;
    }

    mod numbers {
        mod i64;
        mod integer_trait;
    }

    mod utils {
        mod constants;
        mod heuristics;
        mod movement;
        mod map_utils;
    }
}

#[cfg(test)]
mod tests {
    mod setup;
    mod test_marketplace_system;
    mod test_interact_system;
    mod test_jps_system;
}

mod constants;
mod store;
