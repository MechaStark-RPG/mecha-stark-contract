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
    use mecha_stark::components::game_state::{GameState, MechaState};
    use mecha_stark::components::position::{Position};

    #[test]
    #[available_gas(20000000)]
    fn happy_path() {
        let mut calldata = ArrayTrait::new();
        calldata.append(100);
        let (contract_address, _) = deploy_syscall(
            MechaStarkContract::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();

        let contract0 = IMechaStarkContractDispatcher { contract_address };

        let position_default = Position { x: 100, y: 100 };

        // PLAYER 1
        let action_1_player_1 = Action {
            id_mecha: 1,
            first_action: TypeAction::Attack(()),
            movement: position_default,
            attack: Position {
                x: 5, y: 0
            },
        };

        let action_2_player_1 = Action {
            id_mecha: 2,
            first_action: TypeAction::Attack(()),
            movement: position_default,
            attack: Position {
                x: 5, y: 1
            },
        };

        let action_3_player_1 = Action {
            id_mecha: 3,
            first_action: TypeAction::Attack(()),
            movement: position_default,
            attack: Position {
                x: 5, y: 2
            },
        };

        let action_4_player_1 = Action {
            id_mecha: 4,
            first_action: TypeAction::Attack(()),
            movement: position_default,
            attack: Position {
                x: 5, y: 3
            },
        };

        let action_5_player_1 = Action {
            id_mecha: 5,
            first_action: TypeAction::Attack(()),
            movement: position_default,
            attack: Position {
                x: 5, y: 4
            },
        };

        let mut actions_player_1 = ArrayTrait::new();
        actions_player_1.append(action_1_player_1);
        actions_player_1.append(action_2_player_1);
        actions_player_1.append(action_3_player_1);
        actions_player_1.append(action_4_player_1);
        actions_player_1.append(action_5_player_1);

        let id_game = 1;
        let player_1 = starknet::contract_address_const::<1>();
        let turn_player_1 = Turn { id_game, player: player_1, actions: actions_player_1.span() };

        let mecha_state_1_player_1 = MechaState {
            id: 1, hp: 100, position: Position { x: 2, y: 0 }
        };
        let mecha_state_2_player_1 = MechaState {
            id: 2, hp: 100, position: Position { x: 2, y: 1 }
        };
        let mecha_state_3_player_1 = MechaState {
            id: 3, hp: 100, position: Position { x: 2, y: 2 }
        };
        let mecha_state_4_player_1 = MechaState {
            id: 4, hp: 100, position: Position { x: 2, y: 3 }
        };
        let mecha_state_5_player_1 = MechaState {
            id: 5, hp: 100, position: Position { x: 2, y: 4 }
        };

        let mut mechas_player_1 = ArrayTrait::new();
        mechas_player_1.append(mecha_state_1_player_1);
        mechas_player_1.append(mecha_state_2_player_1);
        mechas_player_1.append(mecha_state_3_player_1);
        mechas_player_1.append(mecha_state_4_player_1);
        mechas_player_1.append(mecha_state_5_player_1);

        // PLAYER 2

        let action_1_player_2 = Action {
            id_mecha: 6,
            first_action: TypeAction::Attack(()),
            movement: position_default,
            attack: Position {
                x: 2, y: 0
            },
        };

        let action_2_player_2 = Action {
            id_mecha: 7,
            first_action: TypeAction::Attack(()),
            movement: position_default,
            attack: Position {
                x: 2, y: 1
            },
        };

        let action_3_player_2 = Action {
            id_mecha: 8,
            first_action: TypeAction::Attack(()),
            movement: position_default,
            attack: Position {
                x: 2, y: 2
            },
        };

        let action_4_player_2 = Action {
            id_mecha: 9,
            first_action: TypeAction::Attack(()),
            movement: position_default,
            attack: Position {
                x: 2, y: 3
            },
        };

        let action_5_player_2 = Action {
            id_mecha: 10,
            first_action: TypeAction::Attack(()),
            movement: position_default,
            attack: Position {
                x: 2, y: 4
            },
        };

        let mut actions_player_2 = ArrayTrait::new();
        actions_player_2.append(action_1_player_2);
        actions_player_2.append(action_2_player_2);
        actions_player_2.append(action_3_player_2);
        actions_player_2.append(action_4_player_2);
        actions_player_2.append(action_5_player_2);

        let player_2 = starknet::contract_address_const::<2>();
        let turn_player_2 = Turn { id_game, player: player_2, actions: actions_player_2.span() };

        let mecha_state_1_player_2 = MechaState {
            id: 6, hp: 100, position: Position { x: 5, y: 0 }
        };
        let mecha_state_2_player_2 = MechaState {
            id: 7, hp: 100, position: Position { x: 5, y: 1 }
        };
        let mecha_state_3_player_2 = MechaState {
            id: 8, hp: 100, position: Position { x: 5, y: 2 }
        };
        let mecha_state_4_player_2 = MechaState {
            id: 9, hp: 100, position: Position { x: 5, y: 3 }
        };
        let mecha_state_5_player_2 = MechaState {
            id: 10, hp: 100, position: Position { x: 5, y: 4 }
        };

        let mut mechas_player_2 = ArrayTrait::new();
        mechas_player_2.append(mecha_state_1_player_2);
        mechas_player_2.append(mecha_state_2_player_2);
        mechas_player_2.append(mecha_state_3_player_2);
        mechas_player_2.append(mecha_state_4_player_2);
        mechas_player_2.append(mecha_state_5_player_2);

        // // // //
        let mut turns = ArrayTrait::new();
        turns.append(turn_player_1);
        turns.append(turn_player_2);
        turns.append(turn_player_1);
        turns.append(turn_player_2);
        turns.append(turn_player_1);
        turns.append(turn_player_2);
        turns.append(turn_player_1);
        turns.append(turn_player_2);

        let game_state = GameState {
            id_game,
            player_1,
            player_2,
            mechas_state_player_1: mechas_player_1.span(),
            mechas_state_player_2: mechas_player_2.span()
        };

        assert(contract0.validate_game(game_state, turns) == true, 'Falle en validate game');
    }
}
