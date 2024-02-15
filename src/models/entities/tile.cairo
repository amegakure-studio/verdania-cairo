const T_BRIDGE_ID: u64 = 1;
const T_BUILDING_ID: u64 = 2;
const T_GRASS_ID: u64 = 3;
const T_SAND_ID: u64 = 4;
const T_WATER_ID: u64 = 5;
const T_NOT_WALKABLE_ID: u64 = 6;

#[derive(Model, Copy, Drop, Serde)]
struct Tile {
    #[key]
    map_id: u64,
    #[key]
    id: u64,
    x: u64,
    y: u64,
    tile_type: u64
}

#[derive(Serde, Copy, Drop, PartialEq)]
enum TileType {
    Bridge,
    Building,
    Grass,
    Sand,
    Water,
    NotWalkable
}

trait TileTrait {
    fn new(map_id: u64, id: u64, x: u64, y: u64, tile_type: u64) -> Tile;
}

impl TileImpl of TileTrait {
    fn new(map_id: u64, id: u64, x: u64, y: u64, tile_type: u64) -> Tile {
        Tile { map_id, id, x, y, tile_type }
    }
}

fn is_walkable(tile: Tile) -> bool {
    let tile_type: TileType = tile.tile_type.try_into().expect('Cannot convert tile type');
    tile_type == TileType::Bridge || tile_type == TileType::Grass || tile_type == TileType::Sand
}

fn is_suitable_for_crops(tile: Tile) -> bool {
    let tile_type: TileType = tile.tile_type.try_into().expect('Cannot convert tile type');
    tile_type == TileType::Grass
}

impl TileTypeIntoU64 of Into<TileType, u64> {
    #[inline(always)]
    fn into(self: TileType) -> u64 {
        match self {
            TileType::Bridge => T_BRIDGE_ID,
            TileType::Building => T_BUILDING_ID,
            TileType::Grass => T_GRASS_ID,
            TileType::Sand => T_SAND_ID,
            TileType::Water => T_WATER_ID,
            TileType::NotWalkable => T_NOT_WALKABLE_ID,
        }
    }
}

impl U64TryIntoSkillType of TryInto<u64, TileType> {
    #[inline(always)]
    fn try_into(self: u64) -> Option<TileType> {
        if self == T_BRIDGE_ID {
            Option::Some(TileType::Bridge)
        } else if self == T_BUILDING_ID {
            Option::Some(TileType::Building)
        } else if self == T_GRASS_ID {
            Option::Some(TileType::Grass)
        } else if self == T_SAND_ID {
            Option::Some(TileType::Sand)
        } else if self == T_WATER_ID {
            Option::Some(TileType::Water)
        } else if self == T_NOT_WALKABLE_ID {
            Option::Some(TileType::NotWalkable)
        } else {
            Option::None(())
        }
    }
}
