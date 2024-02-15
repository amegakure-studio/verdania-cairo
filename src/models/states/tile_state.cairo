use starknet::ContractAddress;

const TS_ENVIROMENT_ID: u64 = 1;
const TS_CROP_ID: u64 = 2;

#[derive(Model, Copy, Drop, Serde)]
struct TileState {
    #[key]
    farm_id: u64,
    #[key]
    id: u64,
    entity_type: u64,
    entity_index: u64
}

#[derive(Serde, Copy, Drop, PartialEq)]
enum TileStateT {
    Enviroment,
    Crop
}

impl TileStateTIntoU64 of Into<TileStateT, u64> {
    #[inline(always)]
    fn into(self: TileStateT) -> u64 {
        match self {
            TileStateT::Enviroment => TS_ENVIROMENT_ID,
            TileStateT::Crop => TS_CROP_ID,
        }
    }
}

impl TileStateTTryIntoU64 of TryInto<u64, TileStateT> {
    #[inline(always)]
    fn try_into(self: u64) -> Option<TileStateT> {
        if self == TS_ENVIROMENT_ID {
            Option::Some(TileStateT::Enviroment)
        } else if self == TS_CROP_ID {
            Option::Some(TileStateT::Crop)
        } else {
            Option::None(())
        }
    }
}
