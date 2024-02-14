mod setup {
    // Starknet imports

    use starknet::ContractAddress;
    use starknet::testing::set_contract_address;

    // Dojo imports

    use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    // Internal imports

    // Models
    use verdania::models::data::game::{farm_count, FarmCount};
    use verdania::models::data::world_config::{active_players, ActivePlayers};
    use verdania::models::data::world_config::{global_contract, GlobalContract};
    use verdania::models::data::world_config::{world_config, WorldConfig};
    use verdania::models::entities::crop::{crop, Crop};
    use verdania::models::entities::env_entity::{env_entity, EnvEntity};
    use verdania::models::entities::item::{item, Item};
    use verdania::models::entities::map::{map, Map};
    use verdania::models::entities::marketplace::{marketplace_item, MarketplaceItem};
    use verdania::models::entities::marketplace::{marketplace_meta, MarketplaceMeta};
    use verdania::models::entities::tile::{tile, Tile};
    use verdania::models::entities::interact::{interact, Interact};
    use verdania::models::states::crop_state::{crop_state, CropState};
    use verdania::models::states::env_entity_state::{env_entity_state, EnvEntityState};
    use verdania::models::states::player_farm_state::{player_farm_state, PlayerFarmState};
    use verdania::models::states::player_state::{player_state, PlayerState};
    use verdania::models::states::tile_state::{tile_state, TileState};
    use verdania::models::tokens::erc1155::{erc_1155_balance, ERC1155Balance};
    use verdania::models::tokens::erc1155::{erc_1155_meta, ERC1155Meta};
    use verdania::models::tokens::erc1155::{
        erc_1155_operator_approval, ERC1155OperatorApproval
    };
    use verdania::models::tokens::erc20::{erc_20_allowance, ERC20Allowance};
    use verdania::models::tokens::erc20::{erc_20_balance, ERC20Balance};
    use verdania::models::tokens::erc20::{erc_20_meta, ERC20Meta};

    // Systems
    use verdania::systems::crop_system::{crop_system, ICropSystemDispatcher};
    use verdania::systems::env_entity_system::{env_entity_system, IEnvEntitySystemDispatcher};
    use verdania::systems::farm_factory_system::{
        farm_factory_system, IFarmFactorySystemDispatcher
    };
    use verdania::systems::item_system::{item_system, IItemSystemDispatcher};
    use verdania::systems::map_system::{map_system, IMapSystemDispatcher};
    use verdania::systems::world_config_system::{
        world_config_system, IWorldConfigSystemDispatcher, IWorldConfigSystemDispatcherTrait
    };

    use verdania::systems::marketplace_system::{
        Marketplace, IMarketplaceDispatcher, IMarketplaceDispatcherTrait
    };
    use verdania::systems::interact_system::{
        interact_system, IInteractSystemDispatcher, IInteractSystemDispatcherTrait
    };
    use verdania::interfaces::IERC1155::{IERC1155Dispatcher, IERC1155DispatcherTrait};
    use verdania::interfaces::IERC20::{IERC20Dispatcher, IERC20DispatcherTrait};
    use verdania::systems::erc1155_system::ERC1155;
    use verdania::systems::erc20_system::ERC20;

    // Constants
    use integer::BoundedInt;

    fn OWNER() -> ContractAddress {
        starknet::contract_address_const::<'OWNER'>()
    }

    #[derive(Drop)]
    struct Systems {
        crop_system: ICropSystemDispatcher,
        env_entity_system: IEnvEntitySystemDispatcher,
        erc1155_system: IERC1155Dispatcher,
        erc20_system: IERC20Dispatcher,
        farm_factory_system: IFarmFactorySystemDispatcher,
        item_system: IItemSystemDispatcher,
        map_system: IMapSystemDispatcher,
        marketplace_system: IMarketplaceDispatcher,
        world_config_system: IWorldConfigSystemDispatcher,
        interact_system: IInteractSystemDispatcher,
    }

    fn spawn_game() -> (IWorldDispatcher, Systems) {
        // [Setup] World
        let models = array![
            farm_count::TEST_CLASS_HASH,
            active_players::TEST_CLASS_HASH,
            global_contract::TEST_CLASS_HASH,
            world_config::TEST_CLASS_HASH,
            crop::TEST_CLASS_HASH,
            env_entity::TEST_CLASS_HASH,
            item::TEST_CLASS_HASH,
            map::TEST_CLASS_HASH,
            marketplace_item::TEST_CLASS_HASH,
            marketplace_meta::TEST_CLASS_HASH,
            tile::TEST_CLASS_HASH,
            crop_state::TEST_CLASS_HASH,
            env_entity_state::TEST_CLASS_HASH,
            player_farm_state::TEST_CLASS_HASH,
            player_state::TEST_CLASS_HASH,
            tile_state::TEST_CLASS_HASH,
            erc_1155_balance::TEST_CLASS_HASH,
            erc_1155_meta::TEST_CLASS_HASH,
            erc_1155_operator_approval::TEST_CLASS_HASH,
            erc_20_allowance::TEST_CLASS_HASH,
            erc_20_balance::TEST_CLASS_HASH,
            erc_20_meta::TEST_CLASS_HASH,
            interact::TEST_CLASS_HASH
        ];

        let world = spawn_test_world(models);

        // [Setup] Systems
        let systems = Systems {
            crop_system: ICropSystemDispatcher {
                contract_address: world
                    .deploy_contract('salt', crop_system::TEST_CLASS_HASH.try_into().unwrap())
            },
            env_entity_system: IEnvEntitySystemDispatcher {
                contract_address: world
                    .deploy_contract('salt', env_entity_system::TEST_CLASS_HASH.try_into().unwrap())
            },
            erc1155_system: IERC1155Dispatcher {
                contract_address: world
                    .deploy_contract('salt', ERC1155::TEST_CLASS_HASH.try_into().unwrap())
            },
            erc20_system: IERC20Dispatcher {
                contract_address: world
                    .deploy_contract('salt', ERC20::TEST_CLASS_HASH.try_into().unwrap())
            },
            farm_factory_system: IFarmFactorySystemDispatcher {
                contract_address: world
                    .deploy_contract(
                        'salt', farm_factory_system::TEST_CLASS_HASH.try_into().unwrap()
                    )
            },
            item_system: IItemSystemDispatcher {
                contract_address: world
                    .deploy_contract('salt', item_system::TEST_CLASS_HASH.try_into().unwrap())
            },
            map_system: IMapSystemDispatcher {
                contract_address: world
                    .deploy_contract('salt', map_system::TEST_CLASS_HASH.try_into().unwrap())
            },
            marketplace_system: IMarketplaceDispatcher {
                contract_address: world
                    .deploy_contract('salt', Marketplace::TEST_CLASS_HASH.try_into().unwrap())
            },
            world_config_system: IWorldConfigSystemDispatcher {
                contract_address: world
                    .deploy_contract(
                        'salt', world_config_system::TEST_CLASS_HASH.try_into().unwrap()
                    )
            },
            interact_system: IInteractSystemDispatcher {
                contract_address: world
                    .deploy_contract(
                        'salt', interact_system::TEST_CLASS_HASH.try_into().unwrap()
                    )
            }
        };

        set_contract_address(OWNER());
        let arr = array![
            GlobalContract {
                id: 23588828915041553345745097173581313296708,
                address: systems.erc20_system.contract_address
            },
            GlobalContract {
                id: 1545917490451274575681179362113681226280683844,
                address: systems.erc1155_system.contract_address
            },
            GlobalContract {
                id: 7399574450516941475902137329108170261525607675965950276,
                address: systems.marketplace_system.contract_address
            }
        ];
        systems.world_config_system.init_global_contracts(arr);

        systems.erc20_system.init(1145130053, 4473164, 10000);

        systems.erc1155_system.init();

        systems.marketplace_system.init();
        (world, systems)
    }
}
