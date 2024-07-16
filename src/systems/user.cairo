use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::ContractAddress;

#[starknet::interface]
trait IUser<TContractState> {
    fn init(self: @TContractState, inviteCode: felt252);
    fn user_balance(self: @TContractState, player: ContractAddress) -> u128;
}

#[dojo::contract]
mod User {
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use starknet::{get_caller_address, get_block_timestamp};
    use lethal::constants::{DEFAULT_BALANCE, BOARD_SIZE};
    use lethal::store::{Store, StoreTrait};
    use lethal::events::{Initialized};
    use lethal::models::random::{Random};
    use lethal::models::user_data::{UserData};
    use lethal::models::invitation_code::{InvitationCode};
    use lethal::models::character::{Character, CharacterTrait};
    use super::{ContractAddress, IUser};

    #[abi(embed_v0)]
    impl IUserImpl of IUser<ContractState> {
        fn init(self: @ContractState, inviteCode: felt252) {
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

        fn user_balance(self: @ContractState, player: ContractAddress) -> u128 {
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);
            let user_data = store.user_data(player);

            user_data.balance + store.idle_balance(player)
        }
    }
}