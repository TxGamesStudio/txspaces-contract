use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::ContractAddress;

#[starknet::interface]
trait IAdmin<TContractState> {
    fn seed(self: @TContractState, seed: u128);
    fn add_default_code(self: @TContractState, id: felt252);
}

#[dojo::contract]
mod Admin {
    use core::traits::TryInto;
    use starknet::{get_caller_address};
    use txspaces::store::{Store, StoreTrait};
    use txspaces::models::random::{Random};
    use txspaces::models::invitation_code::{InvitationCode};
    use txspaces::utils::{splitmix, U64};
    use super::{ContractAddress, IAdmin};

    #[abi(embed_v0)]
    impl IAdminImpl of IAdmin<ContractState> {
        fn seed(self: @ContractState, seed: u128) {
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);

            let mut rand = store.random();

            rand.s0 = splitmix(seed);
            rand.s1 = splitmix(rand.s0);
        
            store.set_random(rand);
        }

        fn add_default_code(self: @ContractState, id: felt252) {
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);

            store.set_invitation_code(InvitationCode {
                code: store.generate_code(),
                player: starknet::contract_address_try_from_felt252(id).unwrap(),
                limit: 0,
                usedCount: 0
            });
        }
    }
}