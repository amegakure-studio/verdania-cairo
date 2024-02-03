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

#[derive(Serde, Copy, Drop, PartialEq)]
enum TileType {
    Bridge,
    Building,
    Dirt,
    Grass,
    Montain,
    Sand,
    Water,
}

impl TileTypeIntoU8 of Into<TileType, u8> {
    #[inline(always)]
    fn into(self: TileType) -> u8 {
        match self {
            TileType::Bridge => 1,
            TileType::Building => 2,
            TileType::Dirt => 3,
            TileType::Grass => 4,
            TileType::Montain => 5,
            TileType::Sand => 6,
            TileType::Water => 7,
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
            Option::Some(TileType::Dirt)
        } else if self == 4 {
            Option::Some(TileType::Grass)
        } else if self == 5 {
            Option::Some(TileType::Montain)
        } else if self == 6 {
            Option::Some(TileType::Sand)
        } else if self == 7 {
            Option::Some(TileType::Water)
        } else {
            Option::None(())
        }
    }
}