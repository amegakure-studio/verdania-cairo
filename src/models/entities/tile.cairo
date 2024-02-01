#[derive(Model, Copy, Drop, Serde)]
struct Tile {
    #[key]
    id: u64,
    x: u64,
    y: u64,
    tile_type: u8
}

#[derive(Serde, Copy, Drop, PartialEq)]
enum TileType {
    Dirt,
    Grass,
    Water,
    Structure,
}
