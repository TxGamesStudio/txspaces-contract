use starknet::ContractAddress;
 
#[derive(Model, Copy, Drop, Serde)]
#[dojo::model]
struct InvitationCode {
    #[key]
    code: felt252,
    player: ContractAddress,
    limit: u16,
    usedCount: u16
}