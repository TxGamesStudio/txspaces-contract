use starknet::ContractAddress;
 
#[derive(Model, Drop, Serde)]
struct UserData {
    #[key]
    player: ContractAddress,
    
    initialized: bool,
    balance: u128,
    snapshoted_at: u64
}

trait UserDataTrait {
}

impl UserDataImpl of UserDataTrait {
    
}