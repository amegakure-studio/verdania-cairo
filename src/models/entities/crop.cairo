use verdania::models::data::items_id::{PUMPKIN_ID, ONION_ID, CARROT_ID, CORN_ID, MUSHROOM_ID};

#[derive(Model, Copy, Drop, Serde)]
struct Crop {
    #[key]
    id: u64,
    name: felt252,
    harvest_time: u64,
    min_watering_time: u64,
    drop_item_id: u64,
    quantity: u64,
}

#[derive(Serde, Copy, Drop, PartialEq)]
enum CropT {
    Carrot,
    Corn,
    Mushroom,
    Onion,
    Pumpkin,
}

impl CropTIntoU64 of Into<CropT, u64> {
    #[inline(always)]
    fn into(self: CropT) -> u64 {
        match self {
            CropT::Carrot => CARROT_ID,
            CropT::Corn => CORN_ID,
            CropT::Mushroom => MUSHROOM_ID,
            CropT::Onion => ONION_ID,
            CropT::Pumpkin => PUMPKIN_ID,
        }
    }
}

impl CropTTryIntoU64 of TryInto<u64, CropT> {
    #[inline(always)]
    fn try_into(self: u64) -> Option<CropT> {
        if self == CARROT_ID {
            Option::Some(CropT::Carrot)
        } else if self == CORN_ID {
            Option::Some(CropT::Corn)
        } else if self == MUSHROOM_ID {
            Option::Some(CropT::Mushroom)
        } else if self == ONION_ID {
            Option::Some(CropT::Onion)
        } else if self == PUMPKIN_ID {
            Option::Some(CropT::Pumpkin)
        } else {
            Option::None(())
        }
    }
}
