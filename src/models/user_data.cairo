use starknet::ContractAddress;
 
#[derive(Model, Copy, Drop, Serde)]
#[dojo::model]
struct UserData {
    #[key]
    player: ContractAddress,
    code: felt252,
    
    initialized: bool,
    balance: u128,
    snapshoted_at: u64
}