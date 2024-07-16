use core::traits::Into;
use cubit::f128::types::fixed::{Fixed, FixedTrait, FixedTryIntoU128, ONE_u128};
use cubit::f128::math::{ops};
use starknet::ContractAddress;
 
#[derive(Model, Copy, Drop, Serde)]
#[dojo::model]
struct CharacterLevel {
    #[key]
    player: ContractAddress,
    #[key]
    level: u32,
    count: u32,
}

trait CharacterLevelTrait {
    fn get_price(self: CharacterLevel) -> u128;
}

impl CharacterLevelImpl of CharacterLevelTrait {

    fn get_price(self: CharacterLevel) -> u128 {
        let count: u128 = self.count.into();
        let level: u128 = self.level.into();
        
        let rate = if (level == 1) { 
            FixedTrait::new(107 * ONE_u128 / 100, false)    // 1.07
        } else { 
            FixedTrait::new(1175 * ONE_u128 / 1000, false)  // 1.175 
        };
        let initValue = if (level == 1) { 
            FixedTrait::new_unscaled(100, false) 
        } else { 
            FixedTrait::new_unscaled(1500_u128 * 3_u128^(level-1), false)
        };

        FixedTrait::round(ops::mul(ops::pow(rate, FixedTrait::new_unscaled(count, false)), initValue)).try_into().unwrap()
    }
}