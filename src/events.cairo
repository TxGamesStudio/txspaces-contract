use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
#[dojo::event]
struct Initialized {
    #[key]
    player: ContractAddress,
    initialized: bool,
}

#[derive(Model, Copy, Drop, Serde)]
#[dojo::event]
struct ActionCompleted {
    #[key]
    player: ContractAddress,
    #[key]
    action_id: felt252,
}

#[derive(Model, Copy, Drop, Serde)]
#[dojo::event]
struct CharacterBought {
    #[key]
    player: ContractAddress,
    #[key]
    created_at: u64,
    index: u8,
    level: u16,
}

#[derive(Model, Copy, Drop, Serde)]
#[dojo::event]
struct CharacterMerged {
    #[key]
    player: ContractAddress,
    #[key]
    created_at: u64,
    index1: u8,
    index2: u8,
    prev_level: u16,
    next_level: u16,
}

#[derive(Model, Copy, Drop, Serde)]
#[dojo::event]
struct CharacterDeleted {
    #[key]
    player: ContractAddress,
    #[key]
    created_at: u64,
    index: u8,
    level: u16,
}