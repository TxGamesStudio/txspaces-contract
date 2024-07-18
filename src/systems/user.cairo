use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::ContractAddress;

#[starknet::interface]
trait IUser<TContractState> {
    fn init(self: @TContractState, code: felt252);
    fn whitelisted_init(self: @TContractState);
    fn user_balance(self: @TContractState, player: ContractAddress) -> u128;
}

#[dojo::contract]
mod User {
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use starknet::{get_caller_address, get_block_timestamp};
    use txspaces::constants::{DEFAULT_BALANCE, BOARD_SIZE};
    use txspaces::store::{Store, StoreTrait};
    use txspaces::events::{Initialized};
    use txspaces::models::random::{Random};
    use txspaces::models::user_data::{UserData};
    use txspaces::models::invitation_code::{InvitationCode};
    use txspaces::models::character::{Character, CharacterTrait};
    use super::{ContractAddress, IUser};

    #[abi(embed_v0)]
    impl IUserImpl of IUser<ContractState> {
        fn init(self: @ContractState, code: felt252) {
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);

            let mut ic0 = store.invitation_code(code);
            assert(ic0.player.is_zero(), 'invalid code');
            assert(ic0.limit == 0 || ic0.usedCount < ic0.limit, 'code is fully used');
                
            ic0.usedCount += 1;
            store.set_invitation_code(ic0);

            internal_init(self);
        }

        fn whitelisted_init(self: @ContractState) {
            internal_init(self);
        }

        fn user_balance(self: @ContractState, player: ContractAddress) -> u128 {
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);
            let user_data = store.user_data(player);

            user_data.balance + store.idle_balance(player)
        }
    }

    fn internal_init(self: @ContractState) {
        let player = get_caller_address();
        let world = self.world_dispatcher.read();
        let mut store: Store = StoreTrait::new(world);

        let mut user_data = store.user_data(player);
        assert(!user_data.initialized, 'initialized');
        user_data.initialized = true;
        user_data.balance = DEFAULT_BALANCE;
        user_data.snapshoted_at = starknet::get_block_timestamp();
        loop {
            let code = store.generate_code();
            let mut ic = store.invitation_code(code);
            if (!ic.player.is_zero()) {
                continue;
            }

            ic.player = player;
            ic.limit = 10;
            store.set_invitation_code(ic);
            user_data.code = code;
            break;
        };

        store.set_user_data(user_data);

        let mut index = 0;
        loop {
            store.set_character(Character { pos_idx: index, player, level: 0 });
            index += 1;
            if (index >= BOARD_SIZE) {
                break();
            }
        };

        emit!(world, ( Initialized { player, initialized: true } ));
    }
}