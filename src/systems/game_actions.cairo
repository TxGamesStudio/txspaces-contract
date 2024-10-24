use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::ContractAddress;

use txspaces_dev::models::character::{Character};

#[dojo::interface]
trait IGameActions<TContractState> {
    fn buy(self: @TContractState, action_id: felt252, level: u16);
    fn delete(self: @TContractState, action_id: felt252, idx: u8);
    fn merge(self: @TContractState, action_id: felt252, idx1: u8, idx2: u8);

    fn burnerBuy(self: @TContractState, action_id: felt252, level: u16);
    fn burnerDelete(self: @TContractState, action_id: felt252, idx: u8);
    fn burnerMerge(self: @TContractState, action_id: felt252, idx1: u8, idx2: u8);

    fn get_board(player: ContractAddress) -> Array<Character>;
    fn get_character_idle_rate(levels: Array<u16>) -> Array<u128>;
    fn get_character_prices(buy_counts: Array<u128>, levels: Array<u128>) -> Array<u128>;
}

#[dojo::contract]
mod GameActions {
    use starknet::{get_caller_address};
    use txspaces_dev::store::{Store, StoreTrait};
    use txspaces_dev::events::{ActionCompleted, CharacterBought, CharacterMerged, CharacterDeleted};
    use txspaces_dev::models::burner::{Burner};
    use txspaces_dev::models::user_data::{UserData};
    use txspaces_dev::models::character::{Character, CharacterTrait};
    use txspaces_dev::models::character_level::{CharacterLevel, CharacterLevelTrait};
    use txspaces_dev::models::building_army::{BuildingArmy};
    use super::{ContractAddress, IGameActions};

    #[abi(embed_v0)]
    impl IGameActionsImpl of IGameActions<ContractState> {
        fn buy(self: @ContractState, action_id: felt252, level: u16) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            doBuy(world, player, action_id, level);
        }

        fn burnerBuy(self: @ContractState, action_id: felt252, level: u16) {
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);
            let burner = store.burner(get_caller_address());
            doBuy(world, burner.player, action_id, level);
        }

        fn delete(self: @ContractState, action_id: felt252, idx: u8) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            doDelete(world, player, action_id, idx);
        }

        fn burnerDelete(self: @ContractState, action_id: felt252, idx: u8) {
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);
            let burner = store.burner(get_caller_address());
            doDelete(world, burner.player, action_id, idx);
        }

        fn merge(self: @ContractState, action_id: felt252, idx1: u8, idx2: u8) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            doMerge(world, player, action_id, idx1, idx2);
        }

        fn burnerMerge(self: @ContractState, action_id: felt252, idx1: u8, idx2: u8) {
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);
            let burner = store.burner(get_caller_address());
            doMerge(world, burner.player, action_id, idx1, idx2);
        }

        fn get_board(player: ContractAddress) -> Array<Character> {
            let world = self.world_dispatcher.read();
            let store: Store = StoreTrait::new(world);

            store.board_characters(player)
        }

        fn get_character_idle_rate(levels: Array<u16>) -> Array<u128> {
            let mut res = ArrayTrait::new();
            let len = levels.len();
            let mut index = 0;
            loop {
                res.append(CharacterTrait::get_idle_rate(*levels.at(index)));
                index += 1;
                if (index >= len) {
                    break();
                }
            };

            res
        }

        fn get_character_prices(buy_counts: Array<u128>, levels: Array<u128>) -> Array<u128> {
            assert(buy_counts.len() == levels.len(), 'lengh mismatch');
            let mut res = ArrayTrait::new();
            let len = levels.len();
            let mut index = 0;
            loop {
                res.append(CharacterLevelTrait::get_price_raw(*buy_counts.at(index), *levels.at(index)));
                index += 1;
                if (index >= len) {
                    break();
                }
            };

            res
        }
    }

    fn doBuy(world: IWorldDispatcher, player: ContractAddress, action_id: felt252, level: u16) {
        let mut store: Store = StoreTrait::new(world);
        // store.snapshot_balance(player);

        let army = store.building_army(player);
        assert(army.level >= level, 'execced max level of army building');
            
        let mut user_data = store.user_data(player);
        let mut character_level = store.character_level(player, level);
        
        
        let price = CharacterLevelTrait::get_price(character_level);
        assert(user_data.balance >= price, 'execced balance');
        
        user_data.balance -= price;
        character_level.count += 1;

        let mut idx = 0_u8;
        loop {
            let mut character = store.character(player, idx);

            if (character.level == 0) {
                character.level = level;
                set!(world, (character));
                // store.set_character(character);
                break();
            }

            idx += 1;
            if (idx >= 16) {
                assert(true, 'no space left');
            }
        };

        set!(world, (user_data, character_level));
        
        // store.set_user_data(user_data);
        // store.set_character_level(character_level);
        
        emit!(world, ( ActionCompleted { 
            player,
            action_id
        }));
        emit!(world, ( CharacterBought { 
            player, 
            created_at: starknet::get_block_timestamp(), 
            index: idx, 
            level
        } ));
    }

    fn doMerge(world: IWorldDispatcher, player: ContractAddress, action_id: felt252, idx1: u8, idx2: u8) {
        let mut store: Store = StoreTrait::new(world);
        // store.snapshot_balance(player);
            
        let mut char1 = store.character(player, idx1);
        let mut char2 = store.character(player, idx2);

        assert(char1.level == char2.level, 'not match');

        let army = store.building_army(player);
        assert(army.level > char1.level, 'execced max level of army building');

        char1.level += 1;

        emit!(world, ( ActionCompleted { 
            player,
            action_id
        }));
        emit!(world, ( CharacterMerged { 
            player, 
            created_at: starknet::get_block_timestamp(), 
            index1: idx1, 
            index2: idx2, 
            prev_level: char2.level,
            next_level: char1.level,
        } ));

        char2.level = 0;
        set!(world, (char1, char2));
        // store.set_character(char1);
        // store.set_character(char2);
    }

    fn doDelete(world: IWorldDispatcher, player: ContractAddress, action_id: felt252, idx: u8) {
        let mut store: Store = StoreTrait::new(world);

        let player = get_caller_address();
        // store.snapshot_balance(player);
        let mut char = store.character(player, idx);
        assert(char.level > 0, 'emptied');

        emit!(world, ( ActionCompleted { 
            player,
            action_id
        }));
        emit!(world, ( CharacterDeleted { 
            player, 
            created_at: starknet::get_block_timestamp(), 
            index: idx, 
            level: char.level
        } ));

        char.level = 0;
        set!(world, (char));
        // store.set_character(char);
    }
}