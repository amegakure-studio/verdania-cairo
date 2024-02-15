use starknet::ContractAddress;

const SKIN_BOY_ID: u64 = 1;
const SKIN_GIRL_ID: u64 = 2;

#[derive(Model, Copy, Drop, Serde)]
struct PlayerSkin {
    #[key]
    player: ContractAddress,
    name: felt252,
    gender: u64
}

#[derive(Serde, Copy, Drop, PartialEq)]
enum Gender {
    Boy,
    Girl
}

impl GenderIntoU64 of Into<Gender, u64> {
    #[inline(always)]
    fn into(self: Gender) -> u64 {
        match self {
            Gender::Boy => SKIN_BOY_ID,
            Gender::Girl => SKIN_GIRL_ID,
        }
    }
}

impl u64TryIntoGender of TryInto<u64, Gender> {
    #[inline(always)]
    fn try_into(self: u64) -> Option<Gender> {
        if self == SKIN_BOY_ID {
            Option::Some(Gender::Boy)
        } else if self == SKIN_GIRL_ID {
            Option::Some(Gender::Girl)
        } else {
            Option::None(())
        }
    }
}
