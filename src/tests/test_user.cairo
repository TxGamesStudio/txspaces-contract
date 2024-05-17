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

#[test]
fn test_init() {
    // [Setup]
    let (world, systems, context) = setup::spawn();
    let store = StoreTrait::new(world);

    systems.user.init();

    let user_data = store.user_data(context.player_id);
    assert(user_data.initialized, 'not initialized');
    assert(user_data.balance == DEFAULT_BALANCE, 'invalid balance value');
}

