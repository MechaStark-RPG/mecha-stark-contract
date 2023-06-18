use mecha_stark::game::entities::{Action, Game, Position};

#[starknet::interface]
trait IMechaStarkContract<T> {
    fn create_game(ref self: T);
    fn validate_game(ref self: T, actions: Array<Action>);
    fn get_game(self: @T, id_game: u128) -> u32;
}

#[starknet::contract]
mod MechaStarkContract {
    
    use traits::Into;
    use array::ArrayTrait;
    use starknet::ContractAddress;

    use super::{Action, Game, Position};
    // use mecha_stark::storage::{GameStorageAccess};
    // use mecha_stark::serde::{SpanSerde};

    #[storage]
    struct Storage {
        counter: u128, 
        // game: LegacyMap::<u128, Game>,
    }

    #[constructor]
    fn init(ref self: ContractState, initial_counter: u128) {
        self.counter.write(initial_counter);
    }

    #[external(v0)]
    impl MechaStarkContract of super::IMechaStarkContract<ContractState> {
        
        fn create_game(ref self: ContractState) {

        }
        
        fn validate_game(ref self: ContractState, actions: Array<Action>) {
            let mut action_0 = *actions.at(0);
            // self.counter.read()
            // action_0.id_mecha
            // action_0.attack.x
        }

        fn get_game(self: @ContractState, id_game: u128) -> u32 {
            100
        }
    }
}
