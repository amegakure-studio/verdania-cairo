#[derive(Model, Copy, Drop, Serde)]
struct Tile {
    #[key]
    map_id: u64,
    #[key]
    id: u64,
    x: u64,
    y: u64,
    tile_type: u8
}

trait TileTrait {
    fn new(map_id: u64, id: u64, x: u64, y: u64, tile_type: u8) -> Tile;
}

impl TileImpl of TileTrait {
    fn new(map_id: u64, id: u64, x: u64, y: u64, tile_type: u8) -> Tile {
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

impl TileTypeIntoU8 of Into<TileType, u8> {
    #[inline(always)]
    fn into(self: TileType) -> u8 {
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

impl U8TryIntoSkillType of TryInto<u8, TileType> {
    #[inline(always)]
    fn try_into(self: u8) -> Option<TileType> {
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