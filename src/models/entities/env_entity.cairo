use verdania::models::data::env_entity_id::{
    ENV_SUITABLE_FOR_CROP, ENV_PUMPKIN_ID, ENV_ONION_ID, ENV_CARROT_ID, ENV_CORN_ID,
    ENV_MUSHROOM_ID, ENV_TREE_ID, ENV_ROCK_ID
};
use verdania::models::entities::crop::CropT;
use core::fmt::{Debug, Formatter, Error, Display};

#[derive(Model, Copy, Drop, Serde)]
struct EnvEntity {
    #[key]
    id: u64,
    name: felt252,
    drop_item_id: u64,
    quantity: u64,
    durability: u8
}

#[derive(Serde, Copy, Drop, PartialEq)]
enum EnvEntityT {
    Tree,
    Rock,
    Pumpkin,
    Carrot,
    Onion,
    Corn,
    Mushroom,
    SuitableForCrop
}

impl DisplayEnvEntityT of Display<EnvEntityT> {
    fn fmt(self: @EnvEntityT, ref f: Formatter) -> Result<(), Error> {
        let a: u64 = (*self).into();
        Display::fmt(@a, ref f)
    }
}

fn is_crop(entity: EnvEntityT) -> bool {
    entity == EnvEntityT::Pumpkin
        || entity == EnvEntityT::Carrot
        || entity == EnvEntityT::Onion
        || entity == EnvEntityT::Corn
        || entity == EnvEntityT::Mushroom
}

impl CropTIntoEnvEntityT of Into<CropT, EnvEntityT> {
    #[inline(always)]
    fn into(self: CropT) -> EnvEntityT {
        match self {
            CropT::Carrot => EnvEntityT::Carrot,
            CropT::Corn => EnvEntityT::Corn,
            CropT::Mushroom => EnvEntityT::Mushroom,
            CropT::Onion => EnvEntityT::Onion,
            CropT::Pumpkin => EnvEntityT::Pumpkin
        }
    }
}

impl EnvEntityTTryIntoCropT of TryInto<EnvEntityT, CropT> {
    #[inline(always)]
    fn try_into(self: EnvEntityT) -> Option<CropT> {
        match self {
            EnvEntityT::Tree => Option::None(()),
            EnvEntityT::Rock => Option::None(()),
            EnvEntityT::Pumpkin => Option::Some(CropT::Pumpkin),
            EnvEntityT::Carrot => Option::Some(CropT::Carrot),
            EnvEntityT::Onion => Option::Some(CropT::Onion),
            EnvEntityT::Corn => Option::Some(CropT::Corn),
            EnvEntityT::Mushroom => Option::Some(CropT::Mushroom),
            EnvEntityT::SuitableForCrop => Option::None(()),
        }
    }
}

impl EnvEntityTIntoU64 of Into<EnvEntityT, u64> {
    #[inline(always)]
    fn into(self: EnvEntityT) -> u64 {
        match self {
            EnvEntityT::Tree => ENV_TREE_ID,
            EnvEntityT::Rock => ENV_ROCK_ID,
            EnvEntityT::Pumpkin => ENV_PUMPKIN_ID,
            EnvEntityT::Carrot => ENV_CARROT_ID,
            EnvEntityT::Onion => ENV_ONION_ID,
            EnvEntityT::Corn => ENV_CORN_ID,
            EnvEntityT::Mushroom => ENV_MUSHROOM_ID,
            EnvEntityT::SuitableForCrop => ENV_SUITABLE_FOR_CROP,
        }
    }
}

impl EnvEntityTTryIntoU64 of TryInto<u64, EnvEntityT> {
    #[inline(always)]
    fn try_into(self: u64) -> Option<EnvEntityT> {
        if self == ENV_TREE_ID {
            Option::Some(EnvEntityT::Tree)
        } else if self == ENV_ROCK_ID {
            Option::Some(EnvEntityT::Rock)
        } else if self == ENV_PUMPKIN_ID {
            Option::Some(EnvEntityT::Pumpkin)
        } else if self == ENV_CARROT_ID {
            Option::Some(EnvEntityT::Carrot)
        } else if self == ENV_ONION_ID {
            Option::Some(EnvEntityT::Onion)
        } else if self == ENV_CORN_ID {
            Option::Some(EnvEntityT::Corn)
        } else if self == ENV_MUSHROOM_ID {
            Option::Some(EnvEntityT::Mushroom)
        } else if self == ENV_SUITABLE_FOR_CROP {
            Option::Some(EnvEntityT::SuitableForCrop)
        } else {
            Option::None(())
        }
    }
}
