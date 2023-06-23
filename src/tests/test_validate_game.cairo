#[cfg(test)]
mod tests {
    use core::traits::Into;
    use core::result::ResultTrait;
    use starknet::syscalls::deploy_syscall;
    use array::ArrayTrait;
    use traits::TryInto;
    use option::OptionTrait;
    use starknet::class_hash::Felt252TryIntoClassHash;

    use mecha_stark::game_contract::{
        MechaStarkContract, IMechaStarkContractDispatcher, IMechaStarkContractDispatcherTrait
    };
    
    use mecha_stark::components::turn::{Action, ActionTrait, TypeAction, Turn};
    use mecha_stark::components::game::{Game, MechaAttributes};
    use mecha_stark::components::game_state::{GameState, PlayerState, MechaState};
    use mecha_stark::components::position::{Position};

    #[test]
    #[available_gas(300000000)]
    fn test_validate_game() {
        let mut calldata = ArrayTrait::new();
        calldata.append(100);
        let (contract_address, _) = deploy_syscall(
            MechaStarkContract::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();

        let contract0 = IMechaStarkContractDispatcher { contract_address };

        let id_game = 1;
        let id_mecha = 103; // convertir a ContractAddress
        let first_action = TypeAction::Movement(()); // tiene que ser un enum
        let movement = Position { x: 1, y: 2 };
        let attack = Position { x: 999, y: 1 };
        let action = Action { id_mecha, first_action, movement, attack };
        let mut actions = ArrayTrait::new();
        actions.append(action);
        
        let turn = Turn { id_game, player: starknet::contract_address_const::<10>(), actions: actions.span() };
        
        let mut turns = ArrayTrait::new();
        
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);
        turns.append(turn);

        let mecha_state = MechaState { id: 1, hp: 100, position: Position { x: 1, y: 1 } };
        let mut mechas = ArrayTrait::new();
        mechas.append(mecha_state);
        
        let player_state = PlayerState { owner: starknet::contract_address_const::<10>(), mechas: mechas.span() };
        let mut players = ArrayTrait::new();
        players.append(player_state);
        let game_state = GameState { id_game: 1, players: players.span() };
        
        // contract0.validate_game(actions);
        assert(contract0.validate_game(game_state, turns) == false, 'Falle en validate game');
    }
}
