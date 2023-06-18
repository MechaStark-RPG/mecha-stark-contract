use mecha_stark::entities::{Action, Position};

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

    use mecha_stark::entities::{Action, Game, Position};
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

#[cfg(test)]
mod tests {
    use array::ArrayTrait;
    use core::result::ResultTrait;
    use core::traits::Into;
    use option::OptionTrait;
    use traits::TryInto;

    use starknet::syscalls::deploy_syscall;
    
    use test::test_utils::assert_eq;

    use super::{MechaStarkContract, IMechaStarkContract, IMechaStarkContractDispatcher, IMechaStarkContractDispatcherTrait};
    use super::{Action, Position};


    #[test]
    #[available_gas(30000000)]
    fn test_flow() {
        let mut calldata = Default::default();
        calldata.append(100);
        let (address0, _) = deploy_syscall(
            MechaStarkContract::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        ).unwrap();

        let mut contract0 = IMechaStarkContractDispatcher { contract_address: address0 };

        let mut actions = ArrayTrait::new();
        let id_mecha = 103; // convertir a ContractAddress
        let first_action = 1; // tiene que ser un enum
        let movement = Position { x: 1, y:  2};
        let attack = Position { x: 999, y: 1 };
        let action = Action { id_mecha, first_action, movement, attack };
        actions.append(action);

        // assert_eq(@contract0.validate_game(actions), @999, 'contract0.get() == 100');
        assert_eq(@contract0.get_game(1), @100, 'contract0.get() == 100');
    }
}