use starknet::ContractAddress;
 
#[derive(Model, Copy, Drop, Serde)]
#[dojo::model]
struct Burner {
    #[key]
    burner: ContractAddress,
    player: ContractAddress
}