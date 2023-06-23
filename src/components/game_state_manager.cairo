use array::{ArrayTrait, SpanTrait};
use starknet::{ContractAddress, get_caller_address};


use mecha_stark::components::turn::{Action, ActionTrait, TypeAction, Turn};
use mecha_stark::components::game::{Game, StatusGame, MechaAttributes};
use mecha_stark::components::game_state::{GameState, PlayerState, MechaState};
use mecha_stark::components::position::{Position, PositionTrait};
use mecha_stark::components::mecha_data_helper::{
    MechaDict, MechaDictTrait, MechaStaticData, MechaStaticDataTrait
};
use mecha_stark::utils::storage::{GameStorageAccess};
use mecha_stark::utils::serde::{SpanSerde};


fn _validate_game(game_state: GameState, turns: Array<Turn>) -> bool {
    let mut mecha_dict = load_initial_state(game_state);
    let mut mecha_static_data = load_static_data(game_state);
    
    let mut valid = true;
    let mut idx = 0;
    loop {
        if idx == turns.len() {
            break ();
        }
        let mut idy = 0;
        let mut actions: Span<Action> = *turns.at(idx).actions;
        let player = *turns.at(idx).player;

        // Validar que el jugador sea el que le toca
        
        loop {
            if idy == actions.len() {
                break ();
            }

            let action = *actions.at(idy);
            if !validate_and_execute_action(
                player, action, ref mecha_dict, ref mecha_static_data
            ) {
                // HIZO TRAMPA
                // emitir evento de trampa
                valid = false;
                break ();
            }
            
            // if is_game_finished(
            //     game_state.players, ref mecha_dict, ref mecha_static_data
            // ) { // TERMINO EL JUEGO
            //     valid = true;
            //     break ();
            // }
            idy += 1;
        };
        idx += 1;
    };
    valid
}

fn load_initial_state(game_state: GameState) -> MechaDict {
    let mut mecha_dict = MechaDictTrait::new();
    _load_initial_state(game_state.players, 0, mecha_dict)
}

fn _load_initial_state(
    players: Span<PlayerState>, idx: usize, mut mecha_dict: MechaDict
) -> MechaDict {
    if players.len() == idx {
        return mecha_dict;
    }
    let owner = *players.at(idx).owner;

    let mut idy = 0;
    loop {
        let states: Span<MechaState> = *players.at(idx).mechas;
        if idy == states.len() {
            break ();
        }
        let mecha_state = *states.at(idy);
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);
        idy += 1;
    };
    _load_initial_state(players, idx + 1, mecha_dict)
}

fn load_static_data(game_state: GameState) -> MechaStaticData {
    let mut mecha_data = MechaStaticDataTrait::new();
    _load_static_data(game_state.players, 0, mecha_data, 1)
}

fn _load_static_data(
    players: Span<PlayerState>,
    idx: usize,
    mut mecha_data: MechaStaticData,
    mut mecha_spoof_id: u128
) -> MechaStaticData {
    if players.len() == idx {
        return mecha_data;
    }
    let owner = *players.at(idx).owner;

    let mut idy = 0;
    loop {
        let states: Span<MechaState> = *players.at(idx).mechas;
        if idy == states.len() {
            break ();
        }
        // pedir al contrato los atributos del mecha por states
        let attribute = spoof_mecha_attributes(mecha_spoof_id);
        mecha_data.insert_mecha_data(owner, attribute);
        idy += 1;
        mecha_spoof_id += 1;
    };
    _load_static_data(players, idx + 1, mecha_data, mecha_spoof_id)
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

            if action.attack.has_default_value() {
                if !action.validate_attack(player, ref mecha_dict, ref mecha_static_data) {
                    return false;
                }
                mecha_dict.update_mecha_hp(action.id_mecha, action.attack, ref mecha_static_data);
            }
        },
        TypeAction::Attack(()) => {
            if action.attack.has_default_value() {
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
            attack: 10,
            armor: 10,
            movement: 5,
            attack_shoot_distance: 4,
            attack_meele_distance: 2,
        }
    }
    // fn is_game_finished(
    //     players: Span<PlayerState>,
    //     ref mecha_dict: MechaDict,
    //     ref mecha_static_data: MechaStaticData
    // ) -> bool {
    //     let mut idx = 0;
    //     let mut live_players = 0;
    //     loop {
    //         if idx == players.len() {
    //             break ();
    //         }
    //         if live_players == 2 {
    //             break ();
    //         }
    //         let player = *players.at(idx).owner;
    //         if !is_player_finished(player, ref mecha_dict, ref mecha_static_data) {
    //             live_players += 1;
    //         }
    //         idx += 1;
    //     };
    //     live_players == 1
    // }

    // fn is_player_finished(
    //     player: ContractAddress, ref mecha_dict: MechaDict, ref mecha_static_data: MechaStaticData
    // ) -> bool {
    //     let mechas_by_player = mecha_static_data.get_mechas_ids_by_owner(player);
    //     let mut idx = 0;
    //     let mut dead_mechas = 0;
    //     loop {
    //         if idx == mechas_by_player.len() {
    //             break ();
    //         }
    //         let mecha_id = *mechas_by_player.at(idx);
    //         let mecha_hp = mecha_dict.get_mecha_hp(mecha_id);
    //         if mecha_hp == 0 {
    //             dead_mechas += 1;
    //         }
    //         idx += 1;
    //     };
    //     dead_mechas == mechas_by_player.len()
    // }