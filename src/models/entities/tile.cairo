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

fn is_walkable(tile: Tile) -> bool {
    let tile_type: TileType = tile.tile_type.try_into().expect('Cannot convert tile type');
    tile_type == TileType::Bridge || tile_type == TileType::Grass || tile_type == TileType::Sand
}

fn is_suitable_for_crops(tile: Tile) -> bool {
    let tile_type: TileType = tile.tile_type.try_into().expect('Cannot convert tile type');
    tile_type == TileType::Grass
}

trait TileTrait {
    fn new(map_id: u64, id: u64, x: u64, y: u64, tile_type: u64) -> Tile;
}

impl TileImpl of TileTrait {
    fn new(map_id: u64, id: u64, x: u64, y: u64, tile_type: u64) -> Tile {
        Tile { map_id, id, x, y, tile_type }
    }
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

impl TileTypeIntoU8 of Into<TileType, u64> {
    #[inline(always)]
    fn into(self: TileType) -> u64 {
        match self {
            TileType::Bridge => 1,
            TileType::Building => 2,
            TileType::Grass => 3,
            TileType::Sand => 4,
            TileType::Water => 5,
            TileType::NotWalkable => 6,
        }
    }
}

impl U8TryIntoSkillType of TryInto<u64, TileType> {
    #[inline(always)]
    fn try_into(self: u64) -> Option<TileType> {
        if self == 1 {
            Option::Some(TileType::Bridge)
        } else if self == 2 {
            Option::Some(TileType::Building)
        } else if self == 3 {
            Option::Some(TileType::Grass)
        } else if self == 4 {
            Option::Some(TileType::Sand)
        } else if self == 5 {
            Option::Some(TileType::Water)
        } else if self == 6 {
            Option::Some(TileType::NotWalkable)
        } else {
            Option::None(())
        }
    }
}
