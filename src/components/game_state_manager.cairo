use array::{ArrayTrait, SpanTrait};
use starknet::{ContractAddress, get_caller_address};


use mecha_stark::components::turn::{Action, ActionTrait, TypeAction, Turn};
use mecha_stark::components::game::{Game, GameStatus, MechaAttributes};
use mecha_stark::components::game_state::{GameState, MechaState};
use mecha_stark::components::position::{Position, PositionTrait};
use mecha_stark::components::mecha_data_helper::{
    MechaDict, MechaDictTrait, MechaStaticData, MechaStaticDataTrait
};
use mecha_stark::utils::storage::{GameStorageAccess};
use mecha_stark::utils::serde::{SpanSerde};

fn _validate_game(game_state: GameState, turns: Array<Turn>) -> GameStatus {
    let mut mecha_dict = load_initial_state(game_state);
    let mut mecha_static_data = load_static_data(game_state);

    // validar game states
    assert(game_state.mechas_state_player_1.len() == 5, '');
    assert(game_state.mechas_state_player_2.len() == 5, '');

    let player_1 = game_state.player_1;
    let mut ret = GameStatus::Winner1(());
    let mut valid = true;
    let mut idx = 0;
    loop {
        if idx == turns.len() {
            break ();
        }
        let mut actions: Span<Action> = *turns.at(idx).actions;
        let player = *turns.at(idx).player;

        // validar que sea su turno

        let mut idy = 0;
        loop {
            if idy == actions.len() {
                break ();
            }

            let action = *actions.at(idy);

            if !validate_and_execute_action(player, action, ref mecha_dict, ref mecha_static_data) {
                // HIZO TRAMPA
                // emitir evento
                if player == game_state.player_1 {
                    ret = GameStatus::Cheater1(());
                } else {
                    ret = GameStatus::Cheater2(());
                }
                valid = false;
                break ();
            }

            if is_game_finished(game_state, ref mecha_dict) {
                if player == game_state.player_2 {
                    ret = GameStatus::Winner2(());
                }
                valid = false;
                break ();
            }
            idy += 1;
        };

        if !valid {
            break ();
        }

        idx += 1;
    };
    ret
}

fn validate_and_execute_action(
    player: ContractAddress,
    action: Action,
    ref mecha_dict: MechaDict,
    ref mecha_static_data: MechaStaticData
) -> bool {
    // el mecha atacante esta vivo
    if mecha_dict.get_mecha_hp(action.id_mecha) == 0 {
        return false;
    }

    match action.first_action {
        TypeAction::Movement(()) => {
            if !action.movement.has_default_value() {
                if !action.validate_movement(player, ref mecha_dict, ref mecha_static_data) {
                    return false;
                }
                mecha_dict.update_mecha_position(action.id_mecha, action.movement);
            }

            if !action.attack.has_default_value() {
                if !action.validate_attack(player, ref mecha_dict, ref mecha_static_data) {
                    return false;
                }
                mecha_dict.update_mecha_hp(action.id_mecha, action.attack, ref mecha_static_data);
            }
        },
        TypeAction::Attack(()) => {
            if !action.attack.has_default_value() {
                if !action.validate_attack(player, ref mecha_dict, ref mecha_static_data) {
                    return false;
                }
                mecha_dict.update_mecha_hp(action.id_mecha, action.attack, ref mecha_static_data);
            }

            if !action.movement.has_default_value() {
                if !action.validate_movement(player, ref mecha_dict, ref mecha_static_data) {
                    return false;
                }
                mecha_dict.update_mecha_position(action.id_mecha, action.movement);
            }
        },
    }
    return true;
}

fn spoof_mecha_attributes(id: u128) -> MechaAttributes {
    MechaAttributes {
        id,
        hp: 100,
        attack: 55,
        armor: 10,
        movement: 5,
        attack_shoot_distance: 4,
        attack_meele_distance: 2,
    }
}

fn load_initial_state(game_state: GameState) -> MechaDict {
    let mut mecha_dict = MechaDictTrait::new();

    let mut idx = 0;
    loop {
        if idx == 5 {
            break ();
        }
        let mecha_state = *game_state.mechas_state_player_1.at(idx);
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);
        idx += 1;
    };

    idx = 0;
    loop {
        if idx == 5 {
            break ();
        }
        let mecha_state = *game_state.mechas_state_player_2.at(idx);
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);
        idx += 1;
    };

    mecha_dict
}

fn load_static_data(game_state: GameState) -> MechaStaticData {
    let mut mecha_data = MechaStaticDataTrait::new();
    let mut idx = 0;
    loop {
        if idx == 5 {
            break ();
        }
        let mecha_state = *game_state.mechas_state_player_1.at(idx);
        let attribute = spoof_mecha_attributes(mecha_state.id);
        mecha_data.insert_mecha_data(game_state.player_1, attribute);
        idx += 1;
    };

    idx = 0;
    loop {
        if idx == 5 {
            break ();
        }
        let mecha_state = *game_state.mechas_state_player_2.at(idx);
        let attribute = spoof_mecha_attributes(mecha_state.id);
        mecha_data.insert_mecha_data(game_state.player_2, attribute);
        idx += 1;
    };
    mecha_data
}

fn is_game_finished(game_state: GameState, ref mecha_dict: MechaDict, ) -> bool {
    let mut dead_mechas_player_1 = 0;
    let mut dead_mechas_player_2 = 0;
    let mut idx = 0;
    loop {
        if idx == 5 {
            break ();
        }
        let mecha_state = *game_state.mechas_state_player_1.at(idx);
        let mecha_hp = mecha_dict.get_mecha_hp(mecha_state.id);
        if mecha_hp == 0 {
            dead_mechas_player_1 += 1;
        }
        idx += 1;
    };

    idx = 0;
    loop {
        if idx == 5 {
            break ();
        }
        let mecha_state = *game_state.mechas_state_player_2.at(idx);
        let mecha_hp = mecha_dict.get_mecha_hp(mecha_state.id);
        if mecha_hp == 0 {
            dead_mechas_player_2 += 1;
        }
        idx += 1;
    };
    dead_mechas_player_1 == 5 | dead_mechas_player_2 == 5
}
