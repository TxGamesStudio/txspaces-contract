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
use lethal::systems::admin::{IAdminDispatcherTrait};
use lethal::systems::user::{IUserDispatcherTrait};

#[test]
fn test_init() {
    // [Setup]
    let (world, systems, context) = setup::spawn();
    let store = StoreTrait::new(world);

    systems.admin.seed(0x506C616E74207472656573);
    systems.admin.add_default_code(0x1);
    systems.admin.add_default_code(0x2);
    systems.admin.add_default_code(0x3);

    systems.user.init('');

    let user_data_0 = store.user_data(context.player_id);
    assert(user_data_0.initialized, 'not initialized');
    assert(user_data_0.balance == DEFAULT_BALANCE, 'invalid balance value');
    user_data_0.code.print();

    let player1 = starknet::contract_address_const::<'PLAYER1'>();
    set_contract_address(player1);
    systems.user.init(user_data_0.code);

    let user_data_1 = store.user_data(player1);
    assert(user_data_1.initialized, 'not initialized');
    assert(user_data_1.balance == DEFAULT_BALANCE, 'invalid balance value');
    user_data_1.code.print();
    
}

