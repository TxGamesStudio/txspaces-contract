mod setup {
    // Core imports
    use core::option::OptionTrait;
use core::debug::PrintTrait;

    // Starknet imports
    use starknet::ContractAddress;
    use starknet::testing::{set_contract_address};

    // Dojo imports
    use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    // Internal imports
    use lethal::models::user_data::UserData;
    use lethal::models::character::Character;
    use lethal::models::character_level::CharacterLevel;

    use lethal::systems::user::{User as user_actions, IUserDispatcher, IUserDispatcherTrait};
    use lethal::systems::game_actions::{GameActions as game_actions, IGameActionsDispatcher, IGameActionsDispatcherTrait};

    // Constants

    fn PLAYER() -> ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    const PLAYER_NAME: felt252 = 'PLAYER';

    #[derive(Drop)]
    struct Context {
        player_id: ContractAddress,
        player_name: felt252,
    }

    #[derive(Drop)]
    struct Systems {
        user: IUserDispatcher,
        game_actions: IGameActionsDispatcher,
    }

    #[inline(always)]
    fn spawn() -> (IWorldDispatcher, Systems, Context) {
        // [Setup] World
        let mut models = core::array::ArrayTrait::new();
        models.append(lethal::models::user_data::user_data::TEST_CLASS_HASH);
        models.append(lethal::models::character::character::TEST_CLASS_HASH);
        models.append(lethal::models::character_level::character_level::TEST_CLASS_HASH);
        let world = spawn_test_world(models);

        // // [Setup] Systems
        let user_address = world.deploy_contract('user', user_actions::TEST_CLASS_HASH.try_into().unwrap());
        let game_actions_address = world.deploy_contract('game_actions', game_actions::TEST_CLASS_HASH.try_into().unwrap());
        let systems = Systems {
            user: IUserDispatcher { contract_address: user_address }, 
            game_actions: IGameActionsDispatcher { contract_address: game_actions_address },
        };

        // [Setup] Context
        set_contract_address(PLAYER());
        let context = Context {
            player_id: PLAYER(),
            player_name: PLAYER_NAME
        };

        // [Return]
        (world, systems, context)
    }
}