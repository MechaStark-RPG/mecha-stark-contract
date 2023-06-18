#[cfg(test)]
mod tests {
    use array::ArrayTrait;
    use core::result::ResultTrait;
    use core::traits::Into;
    use option::OptionTrait;
    use traits::TryInto;

    use starknet::syscalls::deploy_syscall;
    
    use test::test_utils::assert_eq;

    use mecha_stark::game::game::{MechaStarkContract, IMechaStarkContract, IMechaStarkContractDispatcher, IMechaStarkContractDispatcherTrait};
    use mecha_stark::game::entities::{Action, Game, Position};


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
