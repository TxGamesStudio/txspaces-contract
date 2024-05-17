// Core imports
use core::debug::PrintTrait;

// Starknet imports
use starknet::testing::set_contract_address;

// Dojo imports
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports
use lethal::constants::{DEFAULT_BALANCE};
use lethal::store::{Store, StoreTrait};
use lethal::tests::setup::{setup, setup::Systems, setup::Context};
use lethal::systems::user::{IUserDispatcherTrait};
use lethal::systems::game_actions::{IGameActionsDispatcher, IGameActionsDispatcherTrait};

#[test]
fn test_character() {
    // [Setup]
    let (world, systems, context) = setup::spawn();
    let store = StoreTrait::new(world);
    systems.user.init();

    systems.game_actions.buy(1);

    // let mut user_data = store.user_data(context.player_id);
    // assert(user_data.balance == DEFAULT_BALANCE - 100, 'invalid balance value');

    // systems.game_actions.buy(1);
    // user_data = store.user_data(context.player_id);
    // user_data.balance.print();

    // systems.game_actions.merge(0, 1);
    
    // let mut char0 = store.character(context.player_id, 0);
    // char0.level.print();

    // let rates = systems.game_actions.get_character_idle_rate(array![0,1,2,3,4,5,6,7,8,9,10]);
    // let len = rates.len();
    // let mut index = 0;
    // loop {
    //     (*rates.at(index)).print();
    //     index += 1;
    //     if (index >= len) {
    //         break();
    //     }
    // };
}

