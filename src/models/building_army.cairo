use core::traits::Into;
use starknet::ContractAddress;
 
#[derive(Model, Copy, Drop, Serde)]
#[dojo::model]
struct BuildingArmy {
    #[key]
    player: ContractAddress,
    
    level: u16,
}

trait BuildingArmyTrait {
    fn get_upgrade_price(self: BuildingArmy) -> u128;
}

impl BuildingArmyImpl of BuildingArmyTrait {
    fn get_upgrade_price(self: BuildingArmy) -> u128 {
        10_000 * self.level.into()
    }
}