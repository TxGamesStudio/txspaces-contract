use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::ContractAddress;

use lethal::models::character::{Character};

#[dojo::interface]
trait IGameActions {
    fn buy(level: u16);
    fn delete(idx: u8);
    fn merge(idx1: u8, idx2: u8);

    fn get_board(player: ContractAddress) -> Array<Character>;
    fn get_character_idle_rate(levels: Array<u16>) -> Array<u128>;
}

#[dojo::contract]
mod GameActions {
    use starknet::{get_caller_address};
    use lethal::store::{Store, StoreTrait};
    use lethal::events::{CharacterBought, CharacterMerged, CharacterDeleted};
    use lethal::models::user_data::{UserData};
    use lethal::models::character::{Character, CharacterTrait};
    use lethal::models::character_level::{CharacterLevel, CharacterLevelTrait};
    use super::{ContractAddress, IGameActions};

    #[abi(embed_v0)]
    impl IGameActionsImpl of IGameActions<ContractState> {
        fn buy(self: @ContractState, level: u16) {
            let player = get_caller_address();
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);
            store.snapshot_balance(player);

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
                    store.set_character(character);
                    break();
                }

                idx += 1;
                if (idx >= 16) {
                    assert(true, 'no space left');
                }
            };
            
            store.set_user_data(user_data);
            store.set_character_level(character_level);

            emit!(world, ( CharacterBought { 
                player, 
                created_at: starknet::get_block_timestamp(), 
                index: idx, 
                level
            } ));
        }

        fn delete(self: @ContractState, idx: u8) {
            let player = get_caller_address();
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);
            store.snapshot_balance(player);

            let mut char = store.character(player, idx);
            assert(char.level > 0, 'emptied');

            emit!(world, ( CharacterDeleted { 
                player, 
                created_at: starknet::get_block_timestamp(), 
                index: idx, 
                level: char.level
            } ));

            char.level = 0;
            store.set_character(char);
        }

        fn merge(self: @ContractState, idx1: u8, idx2: u8) {
            let player = get_caller_address();
            let world = self.world_dispatcher.read();
            let mut store: Store = StoreTrait::new(world);
            store.snapshot_balance(player);
            
            let mut char1 = store.character(player, idx1);
            let mut char2 = store.character(player, idx2);

            assert(char1.level == char2.level, 'not match');

            char1.level += 1;

            emit!(world, ( CharacterMerged { 
                player, 
                created_at: starknet::get_block_timestamp(), 
                index1: idx1, 
                index2: idx2, 
                prev_level: char2.level,
                next_level: char1.level,
            } ));

            char2.level = 0;

            store.set_character(char1);
            store.set_character(char2);
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
    }
}