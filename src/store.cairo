//! Store struct and component management methods.

// Core imports
use core::debug::PrintTrait;

// Straknet imports
use starknet::ContractAddress;
use starknet::{get_caller_address, get_block_timestamp};

// Dojo imports
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Models imports
use lethal::constants::{BOARD_SIZE};
use lethal::models::random::{Random};
use lethal::models::user_data::{UserData};
use lethal::models::invitation_code::{InvitationCode};
use lethal::models::character::{Character, CharacterTrait};
use lethal::models::character_level::{CharacterLevel};

use lethal::utils::{rotl, U64};

/// Store struct.
#[derive(Copy, Drop)]
struct Store {
    world: IWorldDispatcher,
}

/// Implementation of the `StoreTrait` trait for the `Store` struct.
#[generate_trait]
impl StoreImpl of StoreTrait {
    #[inline(always)]
    fn new(world: IWorldDispatcher) -> Store {
        Store { world: world }
    }

    fn random(self: Store) -> Random {
        get!(self.world, (1), (Random))
    }

    fn set_random(self: Store, random: Random) {
        set!(self.world, (random))
    }

    #[inline(always)]
    fn user_data(self: Store, player: ContractAddress) -> UserData {
        get!(self.world, (player), (UserData))
    }
    
    #[inline(always)]
    fn invitation_code(self: Store, code: felt252) -> InvitationCode {
        get!(self.world, (code), (InvitationCode))
    }

    #[inline(always)]
    fn set_invitation_code(self: Store, code: InvitationCode) {
        set!(self.world, (code));
    }

    #[inline(always)]
    fn character(self: Store, player: ContractAddress, idx: u8) -> Character {
        assert!(idx < BOARD_SIZE, "invalid position");
        get!(self.world, (player, idx), (Character))
    }

    #[inline(always)]
    fn character_level(self: Store, player: ContractAddress, level: u16) -> CharacterLevel {
        get!(self.world, (player, level), (CharacterLevel))
    }

    #[inline(always)]
    fn set_user_data(self: Store, user_data: UserData) {
        set!(self.world, (user_data))
    }

    #[inline(always)]
    fn set_character(self: Store, character: Character) {
        set!(self.world, (character))
    }

    #[inline(always)]
    fn set_character_level(self: Store, character_level: CharacterLevel) {
        set!(self.world, (character_level))
    }

    // #[inline(always)]
    fn idle_balance(self: Store, player: ContractAddress) -> u128 {
        let user_data = self.user_data(player);
        let elapsed = starknet::get_block_timestamp() - user_data.snapshoted_at;

        let mut balance: u128 = 0;
        let mut index: u8 = 0;
        loop {
            let character = self.character(player, index);
            balance += CharacterTrait::get_idle_rate(character.level) * elapsed.into();

            index += 1;
            if (index >= BOARD_SIZE) {
                break();
            }
        };

        balance
    }

    #[inline(always)]
    fn snapshot_balance(self: Store, player: ContractAddress) {
        let mut user_data = self.user_data(player);
        user_data.balance += self.idle_balance(player);
        user_data.snapshoted_at = starknet::get_block_timestamp();

        self.set_user_data(user_data);
    }

    fn board_characters(self: Store, player: ContractAddress) -> Array<Character> {
        let mut characters = ArrayTrait::new();
        let mut index: u8 = 0;
        loop {
            characters.append(self.character(player, index));

            index += 1;
            if (index >= BOARD_SIZE) {
                break();
            }
        };

        characters
    }

    fn next_random(self: Store) -> u128 {
        let mut random = self.random();
        let result = (rotl(random.s0 * 5, 7) * 9) & U64;

        random.s1 = (random.s1 ^ random.s0) & U64;
        
        random.s0 = (rotl(random.s0, 24) ^ random.s1 ^ (random.s1 * 65536)) & U64;
        random.s1 = (rotl(random.s1, 37) & U64);
        self.set_random(random);

        result
    }

    fn generate_code(self: Store) -> felt252 {
        let mut randNo = self.next_random() ^ 
            starknet::contract_address_to_felt252(get_caller_address()).try_into().unwrap();
        let mut code: u128 = 0;

        let mut index: u8 = 0;
        loop {
            let char = (randNo & 0xff) % 52;
            
            if (char < 26) {
                code = (code * 256) | (char + 65);  // A
            } else {
                code = (code * 256) | (char - 26 + 97);  // a
            }
            
            randNo /= 256;
            index += 1;
            if (index >= 6) {
                break();
            }
        };

        code.try_into().unwrap()
    }
}