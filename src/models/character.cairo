use core::traits::Into;
use starknet::ContractAddress;
use cubit::f128::types::fixed::{Fixed, FixedTrait, FixedTryIntoU128, ONE_u128};
use cubit::f128::math::{ops};

use lethal::constants::{BOARD_SIZE};

#[derive(Model, Drop, Serde)]
struct Character {
    #[key]
    player: ContractAddress,
    #[key]
    pos_idx: u8,
    level: u16
}

trait CharacterTrait {
    fn new(player: ContractAddress, pos_idx: u8, level: u16) -> Character;
    fn get_idle_rate(level: u16) -> u128;
}

impl CharacterImpl of CharacterTrait {
    fn new(player: ContractAddress, pos_idx: u8, level: u16) -> Character {
        assert!(pos_idx < BOARD_SIZE, "invalid position");
        Character { 
            pos_idx: pos_idx,
            player: player,
            level: level
        }
    }

    fn get_idle_rate(level: u16) -> u128 {
        if (level == 0) {
            return 0;
        }
        // 1.59092 * e^(0,7427*x) - 0.0748667
        FixedTrait::round(
            ops::sub(
                ops::mul(
                    FixedTrait::new(1_59092 * ONE_u128 / 100000, false),        // 1.59092
                    ops::exp(
                        ops::mul(
                            FixedTrait::new(742695 * ONE_u128 / 1000000, false),    // 0,742695
                            level.into()
                        )
                    )
                ),
                FixedTrait::new(74_866_7 * ONE_u128 / 10_000_000, false),            // 0.0748667
            )
        ).try_into().unwrap()
    }
}