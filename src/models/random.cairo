use starknet::ContractAddress;
 
#[derive(Model, Copy, Drop, Serde)]
#[dojo::model]
struct Random {
    #[key]
    id: u8,
    s0: u128,
    s1: u128
}