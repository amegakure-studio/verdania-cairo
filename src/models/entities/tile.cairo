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

// TODO: implement Into/TryInto