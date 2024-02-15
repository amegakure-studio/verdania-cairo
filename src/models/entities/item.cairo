use core::option::OptionTrait;
use verdania::models::data::items_id::{
    PICKAXE_ID, HOE_ID, WATERING_CAN_ID, PUMPKIN_SEED_ID, ONION_SEED_ID, CARROT_SEED_ID,
    CORN_SEED_ID, MUSHROOM_SEED_ID, PUMPKIN_ID, ONION_ID, CARROT_ID, CORN_ID, MUSHROOM_ID
};

#[derive(Model, Copy, Drop, Serde)]
struct Item {
    #[key]
    id: u64,
    name: felt252,
    env_entity_id: u64
}

#[derive(Serde, Copy, Drop, PartialEq)]
enum Tool {
    Hoe,
    Pickaxe,
    WateringCan,
}

#[derive(Serde, Copy, Drop, PartialEq)]
enum Seed {
    Carrot,
    Corn,
    Mushroom,
    Onion,
    Pumpkin,
}

fn its_a_valid_item(item_id: u64) -> bool {
    item_id == PICKAXE_ID ||
    item_id == HOE_ID ||
    item_id == WATERING_CAN_ID ||
    item_id == PUMPKIN_SEED_ID ||
    item_id == ONION_SEED_ID ||
    item_id == CARROT_SEED_ID ||
    item_id == CORN_SEED_ID ||
    item_id == MUSHROOM_SEED_ID ||
    item_id == PUMPKIN_ID ||
    item_id == ONION_ID ||
    item_id == CARROT_ID ||
    item_id == CORN_ID ||
    item_id == MUSHROOM_ID
}

fn equip_item_is_a_seed(item_id: u64) -> bool {
    let opt_seed: Option<Seed> = item_id.try_into();
    opt_seed.is_some()
}

fn get_crop_id_from_seed(item_id: u64) -> u64 {
    assert(equip_item_is_a_seed(item_id), 'item_id should be a seed');
    let seed: Seed = item_id.try_into().unwrap();
    match seed {
        Seed::Carrot => CARROT_ID,
        Seed::Corn => CORN_ID,
        Seed::Mushroom => MUSHROOM_ID,
        Seed::Onion => ONION_ID,
        Seed::Pumpkin => PUMPKIN_ID,
    }
}

impl SeedIntoU64 of Into<Seed, u64> {
    #[inline(always)]
    fn into(self: Seed) -> u64 {
        match self {
            Seed::Carrot => CARROT_SEED_ID,
            Seed::Corn => CORN_SEED_ID,
            Seed::Mushroom => MUSHROOM_SEED_ID,
            Seed::Onion => ONION_SEED_ID,
            Seed::Pumpkin => PUMPKIN_SEED_ID,
        }
    }
}

impl SeedTryIntoU64 of TryInto<u64, Seed> {
    #[inline(always)]
    fn try_into(self: u64) -> Option<Seed> {
        if self == CARROT_SEED_ID {
            Option::Some(Seed::Carrot)
        } else if self == CORN_SEED_ID {
            Option::Some(Seed::Corn)
        } else if self == MUSHROOM_SEED_ID {
            Option::Some(Seed::Mushroom)
        } else if self == ONION_SEED_ID {
            Option::Some(Seed::Onion)
        } else if self == PUMPKIN_SEED_ID {
            Option::Some(Seed::Pumpkin)
        } else {
            Option::None(())
        }
    }
}

impl ToolIntoU64 of Into<Tool, u64> {
    #[inline(always)]
    fn into(self: Tool) -> u64 {
        match self {
            Tool::Hoe => HOE_ID,
            Tool::Pickaxe => PICKAXE_ID,
            Tool::WateringCan => WATERING_CAN_ID,
        }
    }
}

impl ToolTryIntoU64 of TryInto<u64, Tool> {
    #[inline(always)]
    fn try_into(self: u64) -> Option<Tool> {
        if self == HOE_ID {
            Option::Some(Tool::Hoe)
        } else if self == PICKAXE_ID {
            Option::Some(Tool::Pickaxe)
        } else if self == WATERING_CAN_ID {
            Option::Some(Tool::WateringCan)
        } else {
            Option::None(())
        }
    }
}
