#[cfg(test)]
mod tests {
    use core::traits::Into;
    use core::result::ResultTrait;
    use starknet::syscalls::deploy_syscall;
    use array::ArrayTrait;
    use traits::TryInto;
    use option::OptionTrait;
    use starknet::class_hash::Felt252TryIntoClassHash;
    
    use mecha_stark::game::game::{MechaStarkContract, IMechaStarkContractDispatcher, IMechaStarkContractDispatcherTrait};
    use mecha_stark::game::entities::{Action, Game, Position};


    #[test]
    #[available_gas(30000000)]
    fn test_flow() {
        let mut calldata = ArrayTrait::new();
        calldata.append(100);
        let (contract_address, _) = deploy_syscall(
            MechaStarkContract::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        ).unwrap();

        let contract0 = IMechaStarkContractDispatcher { contract_address };

        // let mut actions = ArrayTrait::new();
        // let id_mecha = 103; // convertir a ContractAddress
        // let first_action = 1; // tiene que ser un enum
        // let movement = Position { x: 1, y:  2};
        // let attack = Position { x: 999, y: 1 };
        // let action = Action { id_mecha, first_action, movement, attack };
        // actions.append(action);

        // assert_eq(@contract0.validate_game(actions), @999, 'contract0.get() == 100');

        assert(contract0.get_game(1) == 100, 'contract0.get() == 100');
    }
}
