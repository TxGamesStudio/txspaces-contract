use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::ContractAddress;

#[starknet::interface]
trait IUser<TContractState> {
    fn init(self: @TContractState, code: felt252);
    fn whitelisted_init(self: @TContractState);
    fn register_burner(self: @TContractState, burnerAddress: ContractAddress);
    fn user_balance(self: @TContractState, player: ContractAddress) -> u128;
    fn claim_idle_balance(self: @TContractState);
    fn upgrade_head_quarter(self: @TContractState);
    fn upgrade_army(self: @TContractState);
}

#[dojo::contract]
mod User {
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use starknet::{get_caller_address, get_block_timestamp};
    use txspaces_dev::constants::{DEFAULT_BALANCE, BOARD_SIZE};
    use txspaces_dev::store::{Store, StoreTrait};
    use txspaces_dev::events::{Initialized};
    use txspaces_dev::models::random::{Random};
    use txspaces_dev::models::burner::{Burner};
    use txspaces_dev::models::user_data::{UserData};
    use txspaces_dev::models::invitation_code::{InvitationCode};
    use txspaces_dev::models::character::{Character, CharacterTrait};
    use txspaces_dev::models::building_head_quarter::{BuildingHeadQuarter, BuildingHeadQuarterTrait};
    use txspaces_dev::models::building_army::{BuildingArmy, BuildingArmyTrait};
    use super::{ContractAddress, IUser};

    #[abi(embed_v0)]
    impl IUserImpl of IUser<ContractState> {
        fn init(self: @ContractState, code: felt252) {
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);

            let mut ic0 = store.invitation_code(code);
            assert(!ic0.player.is_zero(), 'invalid code');
            assert(ic0.limit == 0 || ic0.usedCount < ic0.limit, 'code is fully used');
                
            ic0.usedCount += 1;
            set!(world, (ic0));
            // store.set_invitation_code(ic0);

            internal_init(self);
        }

        fn whitelisted_init(self: @ContractState) {
            internal_init(self);
        }

        fn register_burner(self: @ContractState, burnerAddress: ContractAddress) {
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);

            let mut b = store.burner(burnerAddress);
            b.player = get_caller_address();
            set!(world, (b));
            // store.set_burner(b);
        }

        fn user_balance(self: @ContractState, player: ContractAddress) -> u128 {
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);
            let user_data = store.user_data(player);

            user_data.balance + store.idle_balance(player)
        }

        fn claim_idle_balance(self: @ContractState) {
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);

            store.snapshot_balance(get_caller_address());
        }

        fn upgrade_head_quarter(self: @ContractState) {
            let player = get_caller_address();
            let world = self.world_dispatcher.read();

            let mut hq = get!(world, (player), (BuildingHeadQuarter));
            let mut user_data = get!(world, (player), (UserData));
            let price = hq.get_upgrade_price();
            assert(user_data.balance >= price, 'execced balance');
            user_data.balance -= price;
            hq.level += 1;

            set!(world, (user_data, hq));
        }

        fn upgrade_army(self: @ContractState) {
            let player = get_caller_address();
            let world = self.world_dispatcher.read();

            let mut army = get!(world, (player), (BuildingArmy));
            let mut user_data = get!(world, (player), (UserData));
            let price = army.get_upgrade_price();
            assert(user_data.balance >= price, 'execced balance');
            user_data.balance -= price;
            army.level += 1;

            set!(world, (user_data, army));
        }
    }

    fn internal_init(self: @ContractState) {
        let player = get_caller_address();
        let world = self.world_dispatcher.read();
        let mut store: Store = StoreTrait::new(world);

        let mut user_data = get!(world, (player), (UserData));
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
            set!(world, (ic));
            // store.set_invitation_code(ic);
            user_data.code = code;
            break;
        };
        let mut hq = get!(world, (player), (BuildingHeadQuarter));
        hq.level = 1;

        let mut army = get!(world, (player), (BuildingArmy));
        army.level = 1;
        
        set!(world, (user_data, hq, army));

        let mut index = 0;
        loop {
            set!(world, (Character { pos_idx: index, player, level: 0 }));
            // store.set_character(Character { pos_idx: index, player, level: 0 });
            index += 1;
            if (index >= BOARD_SIZE) {
                break();
            }
        };

        emit!(world, ( Initialized { player, initialized: true } ));
    }
}