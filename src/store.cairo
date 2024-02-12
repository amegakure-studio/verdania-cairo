//! Store struct and component management methods.

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Components imports
use verdania::models::data::world_config::{WorldConfig, GlobalContract};

use verdania::models::data::game::FarmCount;
use verdania::models::entities::crop::Crop;
use verdania::models::entities::env_entity::EnvEntity;
use verdania::models::entities::item::Item;
use verdania::models::entities::map::Map;
use verdania::models::entities::tile::Tile;
use verdania::models::entities::interact::Interact;

use verdania::models::states::crop_state::CropState;
use verdania::models::states::env_entity_state::EnvEntityState;
use verdania::models::states::player_farm_state::PlayerFarmState;
use verdania::models::states::player_state::PlayerState;
use verdania::models::states::tile_state::TileState;

use verdania::models::tokens::erc20::{ERC20Balance, ERC20Allowance, ERC20Meta};
use verdania::models::tokens::erc1155::{ERC1155Meta, ERC1155OperatorApproval, ERC1155Balance};
use verdania::models::entities::marketplace::{MarketplaceMeta, MarketplaceItem};

use starknet::ContractAddress;

/// Store struct.
#[derive(Drop)]
struct Store {
    world: IWorldDispatcher
}

/// Trait to initialize, get and set components from the Store.
trait StoreTrait {
    fn new(world: IWorldDispatcher) -> Store;
    // Data
    fn get_farm_count(ref self: Store, id: felt252) -> FarmCount;
    fn set_farm_count(ref self: Store, farm_count: FarmCount);
    fn get_map(ref self: Store, id: u64) -> Map;
    fn set_map(ref self: Store, map: Map);
    fn get_tile(ref self: Store, map_id: u64, id: u64) -> Tile;
    fn set_tile(ref self: Store, tile: Tile);
    fn get_item(ref self: Store, id: u64) -> Item;
    fn set_item(ref self: Store, item: Item);
    fn get_crop(ref self: Store, id: u64) -> Crop;
    fn set_crop(ref self: Store, crop: Crop);
    fn get_env_entity(ref self: Store, id: u64) -> EnvEntity;
    fn set_env_entity(ref self: Store, env_entity: EnvEntity);
    fn get_world_config(ref self: Store, id: u64) -> WorldConfig;
    fn set_world_config(ref self: Store, world_config: WorldConfig);
    fn get_global_contract(ref self: Store, id: felt252) -> GlobalContract;
    fn set_global_contract(ref self: Store, global_contract: GlobalContract);

    // State
    fn get_player_farm_state(
        ref self: Store, map_id: u64, player: ContractAddress
    ) -> PlayerFarmState;
    fn set_player_farm_state(ref self: Store, player_farm_state: PlayerFarmState);
    fn get_crop_state(ref self: Store, farm_id: u64, index: u64) -> CropState;
    fn set_crop_state(ref self: Store, crop_state: CropState);
    fn get_env_entity_state(ref self: Store, farm_id: u64, index: u64) -> EnvEntityState;
    fn set_env_entity_state(ref self: Store, env_entity_state: EnvEntityState);
    fn get_tile_state(ref self: Store, farm_id: u64, index: u64) -> TileState;
    fn set_tile_state(ref self: Store, tile_state: TileState);
    fn get_player_state(ref self: Store, player: ContractAddress) -> PlayerState;
    fn set_player_state(ref self: Store, player_state: PlayerState);

    // ERC20
    fn get_erc20_balance(ref self: Store, id: felt252, account: ContractAddress) -> ERC20Balance;
    fn set_erc20_balance(ref self: Store, erc20_balance: ERC20Balance);
    fn get_erc20_allowance(
        ref self: Store, id: felt252, owner: ContractAddress, spender: ContractAddress
    ) -> ERC20Allowance;
    fn set_erc20_allowance(ref self: Store, erc20_allowance: ERC20Allowance);
    fn get_erc20_meta(ref self: Store, id: felt252) -> ERC20Meta;
    fn set_erc20_meta(ref self: Store, erc20_meta: ERC20Meta);

    // ERC1155
    fn get_erc1155_meta(ref self: Store, id: felt252) -> ERC1155Meta;
    fn set_erc1155_meta(ref self: Store, erc1155_meta: ERC1155Meta);
    fn get_erc1155_operator_approval(
        ref self: Store, id: felt252, owner: ContractAddress, operator: ContractAddress
    ) -> ERC1155OperatorApproval;
    fn set_erc1155_operator_approval(
        ref self: Store, erc1155_operator_approval: ERC1155OperatorApproval
    );
    fn get_erc1155_balance(
        ref self: Store, id_contract: felt252, account: ContractAddress, id: u256
    ) -> ERC1155Balance;
    fn set_erc1155_balance(ref self: Store, erc1155_balance: ERC1155Balance);

    // Marketplace
    fn get_marketplace_meta(ref self: Store, id: felt252) -> MarketplaceMeta;
    fn set_marketplace_meta(ref self: Store, marketplace_meta: MarketplaceMeta);
    fn get_marketplace_item(ref self: Store, id: u256) -> MarketplaceItem;
    fn set_marketplace_item(ref self: Store, marketplace_item: MarketplaceItem);

    // Interact
    fn get_interact(ref self: Store, item_id: u64, env_id: u64) -> Interact;
    fn set_interact(ref self: Store, interact: Interact);
}

/// Implementation of the `StoreTrait` trait for the `Store` struct.
impl StoreImpl of StoreTrait {
    #[inline(always)]
    fn new(world: IWorldDispatcher) -> Store {
        Store { world: world }
    }

    // Data

    fn get_farm_count(ref self: Store, id: felt252) -> FarmCount {
        get!(self.world, id, (FarmCount))
    }

    fn set_farm_count(ref self: Store, farm_count: FarmCount) {
        set!(self.world, (farm_count));
    }

    fn get_map(ref self: Store, id: u64) -> Map {
        get!(self.world, id, (Map))
    }

    fn set_map(ref self: Store, map: Map) {
        set!(self.world, (map));
    }

    fn get_tile(ref self: Store, map_id: u64, id: u64) -> Tile {
        get!(self.world, id, (Tile))
    }

    fn set_tile(ref self: Store, tile: Tile) {
        set!(self.world, (tile));
    }

    fn get_item(ref self: Store, id: u64) -> Item {
        get!(self.world, id, (Item))
    }

    fn set_item(ref self: Store, item: Item) {
        set!(self.world, (item));
    }

    fn get_crop(ref self: Store, id: u64) -> Crop {
        get!(self.world, id, (Crop))
    }

    fn set_crop(ref self: Store, crop: Crop) {
        set!(self.world, (crop));
    }

    fn get_env_entity(ref self: Store, id: u64) -> EnvEntity {
        get!(self.world, id, (EnvEntity))
    }

    fn set_env_entity(ref self: Store, env_entity: EnvEntity) {
        set!(self.world, (env_entity));
    }

    fn get_world_config(ref self: Store, id: u64) -> WorldConfig {
        get!(self.world, id, (WorldConfig))
    }

    fn set_world_config(ref self: Store, world_config: WorldConfig) {
        set!(self.world, (world_config));
    }

    fn get_global_contract(ref self: Store, id: felt252) -> GlobalContract {
        get!(self.world, id, (GlobalContract))
    }

    fn set_global_contract(ref self: Store, global_contract: GlobalContract) {
        set!(self.world, (global_contract));
    }

    // State

    fn get_player_farm_state(
        ref self: Store, map_id: u64, player: ContractAddress
    ) -> PlayerFarmState {
        let player_farm_state_key = (map_id, player);
        get!(self.world, player_farm_state_key.into(), (PlayerFarmState))
    }

    fn set_player_farm_state(ref self: Store, player_farm_state: PlayerFarmState) {
        set!(self.world, (player_farm_state));
    }

    fn get_crop_state(ref self: Store, farm_id: u64, index: u64) -> CropState {
        let crop_state_key = (farm_id, index);
        get!(self.world, crop_state_key.into(), (CropState))
    }

    fn set_crop_state(ref self: Store, crop_state: CropState) {
        set!(self.world, (crop_state));
    }

    fn get_env_entity_state(ref self: Store, farm_id: u64, index: u64) -> EnvEntityState {
        let env_entity_state_key = (farm_id, index);
        get!(self.world, env_entity_state_key.into(), (EnvEntityState))
    }

    fn set_env_entity_state(ref self: Store, env_entity_state: EnvEntityState) {
        set!(self.world, (env_entity_state));
    }

    fn get_tile_state(ref self: Store, farm_id: u64, index: u64) -> TileState {
        let tile_state_key = (farm_id, index);
        get!(self.world, tile_state_key.into(), (TileState))
    }

    fn set_tile_state(ref self: Store, tile_state: TileState) {
        set!(self.world, (tile_state));
    }

    fn get_player_state(ref self: Store, player: ContractAddress) -> PlayerState {
        get!(self.world, player, (PlayerState))
    }

    fn set_player_state(ref self: Store, player_state: PlayerState) {
        set!(self.world, (player_state));
    }

    // ERC20
    fn get_erc20_balance(ref self: Store, id: felt252, account: ContractAddress) -> ERC20Balance {
        let erc20_balance_key = (id, account);
        get!(self.world, erc20_balance_key.into(), (ERC20Balance))
    }

    fn set_erc20_balance(ref self: Store, erc20_balance: ERC20Balance) {
        set!(self.world, (erc20_balance));
    }

    fn get_erc20_allowance(
        ref self: Store, id: felt252, owner: ContractAddress, spender: ContractAddress
    ) -> ERC20Allowance {
        let erc20_allowance_key = (id, owner, spender);
        get!(self.world, erc20_allowance_key.into(), (ERC20Allowance))
    }

    fn set_erc20_allowance(ref self: Store, erc20_allowance: ERC20Allowance) {
        set!(self.world, (erc20_allowance));
    }

    fn get_erc20_meta(ref self: Store, id: felt252) -> ERC20Meta {
        get!(self.world, id, (ERC20Meta))
    }

    fn set_erc20_meta(ref self: Store, erc20_meta: ERC20Meta) {
        set!(self.world, (erc20_meta));
    }

    // ERC1155
    fn get_erc1155_meta(ref self: Store, id: felt252) -> ERC1155Meta {
        get!(self.world, id, (ERC1155Meta))
    }

    fn set_erc1155_meta(ref self: Store, erc1155_meta: ERC1155Meta) {
        set!(self.world, (erc1155_meta));
    }

    fn get_erc1155_operator_approval(
        ref self: Store, id: felt252, owner: ContractAddress, operator: ContractAddress
    ) -> ERC1155OperatorApproval {
        let erc1155_operator_approval_key = (id, owner, operator);
        get!(self.world, erc1155_operator_approval_key.into(), (ERC1155OperatorApproval))
    }

    fn set_erc1155_operator_approval(
        ref self: Store, erc1155_operator_approval: ERC1155OperatorApproval
    ) {
        set!(self.world, (erc1155_operator_approval));
    }

    fn get_erc1155_balance(
        ref self: Store, id_contract: felt252, account: ContractAddress, id: u256
    ) -> ERC1155Balance {
        let erc1155_balance_key = (id_contract, account, id);
        get!(self.world, erc1155_balance_key.into(), (ERC1155Balance))
    }

    fn set_erc1155_balance(ref self: Store, erc1155_balance: ERC1155Balance) {
        set!(self.world, (erc1155_balance));
    }

    // Marketplace
    fn get_marketplace_meta(ref self: Store, id: felt252) -> MarketplaceMeta {
        get!(self.world, id, (MarketplaceMeta))
    }

    fn set_marketplace_meta(ref self: Store, marketplace_meta: MarketplaceMeta) {
        set!(self.world, (marketplace_meta));
    }

    fn get_marketplace_item(ref self: Store, id: u256) -> MarketplaceItem {
        get!(self.world, id, (MarketplaceItem))
    }

    fn set_marketplace_item(ref self: Store, marketplace_item: MarketplaceItem) {
        set!(self.world, (marketplace_item));
    }

    fn get_interact(ref self: Store, item_id: u64, env_id: u64) -> Interact {
        let interact_key = (item_id, env_id);
        get!(self.world, interact_key.into(), (Interact))
    }

    fn set_interact(ref self: Store, interact: Interact) {
        set!(self.world, (interact));
    }
}
