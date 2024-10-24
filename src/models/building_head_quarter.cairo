use core::traits::Into;
use starknet::ContractAddress;
 
#[derive(Model, Copy, Drop, Serde)]
#[dojo::model]
struct BuildingHeadQuarter {
    #[key]
    player: ContractAddress,
    
    level: u16,
}

trait BuildingHeadQuarterTrait {
    fn get_bonus_percentage(self: BuildingHeadQuarter) -> u128;
    fn get_minutes_capacity(self: BuildingHeadQuarter) -> u64;
    fn get_upgrade_price(self: BuildingHeadQuarter) -> u128;
}

impl BuildingHeadQuarterImpl of BuildingHeadQuarterTrait {
    // 10_000 means 100%
    fn get_bonus_percentage(self: BuildingHeadQuarter) -> u128 {
        100_u128 * self.level.into()
    }

    fn get_minutes_capacity(self: BuildingHeadQuarter) -> u64 {
        60 + 30 * self.level.into()
    }

    fn get_upgrade_price(self: BuildingHeadQuarter) -> u128 {
        10_000 * self.level.into()
    }
}