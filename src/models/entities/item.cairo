use verdania::models::data::items_id::{PICKAXE_ID, HOE_ID, WATERING_CAN_ID};

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
