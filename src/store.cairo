//! Store struct and component management methods.

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Components imports
use verdania::models::data::world_config::WorldConfig;

use verdania::models::data::game::FarmCount;

use verdania::models::entities::crop::Crop;
use verdania::models::entities::env_entity::EnvEntity;
use verdania::models::entities::inventory_slot::InventorySlot;
use verdania::models::entities::item::Item;
use verdania::models::entities::map::Map;
use verdania::models::entities::market_listed::MarketListed;
use verdania::models::entities::market::Market;
use verdania::models::entities::tile::Tile;

use verdania::models::states::crop_state::CropState;
use verdania::models::states::env_entity_state::EnvEntityState;
use verdania::models::states::player_farm_state::PlayerFarmState;
use verdania::models::states::player_inventory_state::PlayerInventoryState;
use verdania::models::states::player_state::PlayerState;
use verdania::models::states::tile_state::TileState;

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
    fn get_tile(ref self: Store, id: u64) -> Tile;
    fn set_tile(ref self: Store, tile: Tile);
    fn get_item(ref self: Store, id: u64) -> Item;
    fn set_item(ref self: Store, item: Item);
    fn get_crop(ref self: Store, id: u64) -> Crop;
    fn set_crop(ref self: Store, crop: Crop);
    fn get_env_entity(ref self: Store, id: u64) -> EnvEntity;
    fn set_env_entity(ref self: Store, env_entity: EnvEntity);

    // State
    fn get_world_config(ref self: Store, id: u64) -> WorldConfig;
    fn set_world_config(ref self: Store, world_config: WorldConfig);
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
    fn get_player_inventory_state(ref self: Store, player: ContractAddress) -> PlayerInventoryState;
    fn set_player_inventory_state(ref self: Store, player_inventory_state: PlayerInventoryState);
    fn get_inventory_slot(ref self: Store, player: ContractAddress, index: u64) -> InventorySlot;
    fn set_inventory_slot(ref self: Store, inventory_slot: InventorySlot);
    fn get_market(ref self: Store, id: u64) -> Market;
    fn set_market(ref self: Store, market: Market);
    fn get_market_listed(ref self: Store, market_id: u64, index: u64) -> MarketListed;
    fn set_market_listed(ref self: Store, market_listed: MarketListed);
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

    fn get_tile(ref self: Store, id: u64) -> Tile {
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

    // State
    fn get_world_config(ref self: Store, id: u64) -> WorldConfig {
        get!(self.world, id, (WorldConfig))
    }

    fn set_world_config(ref self: Store, world_config: WorldConfig) {
        set!(self.world, (world_config));
    }

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

    fn get_player_inventory_state(
        ref self: Store, player: ContractAddress
    ) -> PlayerInventoryState {
        get!(self.world, player, (PlayerInventoryState))
    }

    fn set_player_inventory_state(ref self: Store, player_inventory_state: PlayerInventoryState) {
        set!(self.world, (player_inventory_state));
    }

    fn get_inventory_slot(ref self: Store, player: ContractAddress, index: u64) -> InventorySlot {
        let inventory_slot_key = (player, index);
        get!(self.world, inventory_slot_key.into(), (InventorySlot))
    }

    fn set_inventory_slot(ref self: Store, inventory_slot: InventorySlot) {
        set!(self.world, (inventory_slot));
    }

    fn get_market(ref self: Store, id: u64) -> Market {
        get!(self.world, id, (Market))
    }

    fn set_market(ref self: Store, market: Market) {
        set!(self.world, (market));
    }

    fn get_market_listed(ref self: Store, market_id: u64, index: u64) -> MarketListed {
        let market_listed_key = (market_id, index);
        get!(self.world, market_listed_key.into(), (MarketListed))
    }

    fn set_market_listed(ref self: Store, market_listed: MarketListed) {
        set!(self.world, (market_listed));
    }
}
