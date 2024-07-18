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
    use txspaces::models::user_data::UserData;
    use txspaces::models::character::Character;
    use txspaces::models::character_level::CharacterLevel;

    use txspaces::systems::admin::{Admin as admin_actions, IAdminDispatcher, IAdminDispatcherTrait};
    use txspaces::systems::user::{User as user_actions, IUserDispatcher, IUserDispatcherTrait};
    use txspaces::systems::game_actions::{GameActions as game_actions, IGameActionsDispatcher, IGameActionsDispatcherTrait};

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
        admin: IAdminDispatcher,
        user: IUserDispatcher,
        game_actions: IGameActionsDispatcher,
    }

    #[inline(always)]
    fn spawn() -> (IWorldDispatcher, Systems, Context) {
        // [Setup] World
        let mut models = core::array::ArrayTrait::new();
        models.append(txspaces::models::user_data::user_data::TEST_CLASS_HASH);
        models.append(txspaces::models::character::character::TEST_CLASS_HASH);
        models.append(txspaces::models::character_level::character_level::TEST_CLASS_HASH);
        let world = spawn_test_world(models);

        // // [Setup] Systems
        let admin_address = world.deploy_contract('admin', admin_actions::TEST_CLASS_HASH.try_into().unwrap(), array![].span());
        let user_address = world.deploy_contract('user', user_actions::TEST_CLASS_HASH.try_into().unwrap(), array![].span());
        let game_actions_address = world.deploy_contract('game_actions', game_actions::TEST_CLASS_HASH.try_into().unwrap(), array![].span());
        let systems = Systems {
            admin: IAdminDispatcher { contract_address: admin_address }, 
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