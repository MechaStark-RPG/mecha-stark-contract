use mecha_stark::components::turn::{Action, Turn};
use mecha_stark::components::game::{Game, MechaAttributes};
use mecha_stark::components::game_state::{GameState, PlayerState, MechaState};
use mecha_stark::components::position::{Position};

#[abi]
trait IMechaStarkContract {
    fn create_game(id_game: u128, new_game: Game);
    fn validate_game(actions: Array<Action>);
    fn get_game(id_game: u128) -> Game;
}

#[contract]
mod MechaStarkContract {
    
    use array::ArrayTrait;
    use dict::Felt252DictTrait;
    use option::OptionTrait;
    use traits::{Into, TryInto};
    use array::SpanTrait;
    use integer::{u128_sqrt, U64IntoFelt252, Felt252TryIntoU128};

    use starknet::ContractAddress;

    use mecha_stark::components::turn::{Action, TypeAction, Turn};
    use mecha_stark::components::game::{Game, MechaAttributes};
    use mecha_stark::components::game_state::{GameState, PlayerState, MechaState};
    use mecha_stark::components::position::{Position};
    use mecha_stark::components::mecha_data_helper::{MechaDict, MechaDictTrait, MechaStaticData, MechaStaticDataTrait};
    use super::IMechaStarkContract;
    use mecha_stark::storage::{GameStorageAccess};
    use mecha_stark::serde::{SpanSerde};

    struct Storage {
        _game: LegacyMap::<u128, Game>,
    }

    #[external]
    fn create_game(id_game: u128, new_game: Game) {
        _game::write(id_game, new_game);
    }

    // HARDCODED FOR NOW
    const MAP_WIDTH: u128 = 30;
    const MAP_HEIGHT: u128 = 14;
    
    // crear un array de actions con el botardo
    #[external]
    fn validate_game(game_state: GameState, turns: Array<Turn>) {        
        let mut mecha_dict = load_initial_state(game_state);
        let mut mecha_static_data = load_static_data(game_state);

        let mut idx = 0;
        loop {
            if idx == turns.len() {
                break ();
            }

            let mut idy = 0;
            let mut actions: Span<Action> = *turns.at(idx).actions;
            let player = *turns.at(idx).player;
            
            loop {

                if idy == actions.len() {
                    break ();
                }

                let action = *actions.at(idx);
                match action.first_action {
                    TypeAction::Movement (()) => {
                        
                        let is_valid_action = validate_action(player, TypeAction::Movement (()), action, ref mecha_dict, ref mecha_static_data);
                        if is_valid_action == false {
                            break ();
                        }
                        // actualizo el state
                        // actualizar la position del mecha
                        mecha_dict.update_mecha_position(action.id_mecha, action.movement);

                        let is_valid_action = validate_action(player, TypeAction::Attack (()), action, ref mecha_dict, ref mecha_static_data);
                        if is_valid_action == false {
                            break ();
                        }

                        // actualizo el state
                        // actualizar el hp del mecha atacado
                        let (_, mecha_attack) = mecha_static_data.get_mecha_data_by_mecha_id(action.id_mecha);
                        let mecha_received_id = mecha_dict.get_mecha_id_by_position(action.attack);
                        if mecha_received_id > 0 {
                            let mecha_received_hp = mecha_dict.get_mecha_hp(mecha_received_id);
                            mecha_dict.update_mecha_hp(mecha_received_id, mecha_received_hp - mecha_attack.attack);
                        }
                    },
                    TypeAction::Attack (()) => {
                        
                        let is_valid_action = validate_action(player, TypeAction::Attack (()), action, ref mecha_dict, ref mecha_static_data);
                        if is_valid_action == false {
                            break ();
                        }
                        // actualizo el state
                        let (_, mecha_attack) = mecha_static_data.get_mecha_data_by_mecha_id(action.id_mecha);
                        let mecha_received_id = mecha_dict.get_mecha_id_by_position(action.attack);
                        if mecha_received_id > 0 {
                            let mecha_received_hp = mecha_dict.get_mecha_hp(mecha_received_id);
                            mecha_dict.update_mecha_hp(mecha_received_id, mecha_received_hp - mecha_attack.attack);
                        }

                        let is_valid_action = validate_action(player, TypeAction::Movement (()), action, ref mecha_dict, ref mecha_static_data);
                        if is_valid_action == false {
                            break ();
                        }
                        // actualizo el state
                        // actualizar la position del mecha
                        mecha_dict.update_mecha_position(action.id_mecha, action.movement);
                        
                    },
                }
                // valido si termino el juego
                idy += 1;
            };
            idx += 1;
        }
    }

    fn validate_action(player: ContractAddress, type_action: TypeAction, action: Action, ref mecha_dict: MechaDict, ref mecha_static_data: MechaStaticData) -> bool {

        match type_action {
            TypeAction::Movement (()) => {
                assert(is_valid_position(action.movement) == true, 'error position out of map');
                if is_valid_position(action.movement) == false {
                    return false;
                }

                if mecha_dict.get_mecha_id_by_position(action.movement.into()) == 0 {
                    return false;
                }

                let (_, mecha_attributes) = mecha_static_data.get_mecha_data_by_mecha_id(action.id_mecha); 
                let mecha_distance = distance(
                        mecha_dict.get_position_by_mecha_id(action.id_mecha), 
                        action.movement
                    );
                if mecha_distance > mecha_attributes.movement {
                    return false;
                }
            },
            TypeAction::Attack (()) => {
                assert(is_valid_position(action.attack) == true, 'error position out of map');
                if is_valid_position(action.attack) == false {
                    return false;
                }

                if mecha_dict.get_mecha_id_by_position(action.attack.into()) == 0 {
                    return false;
                }

                let (_, mecha_attributes) = mecha_static_data.get_mecha_data_by_mecha_id(action.id_mecha); 
                let mecha_distance = distance(
                        mecha_dict.get_position_by_mecha_id(action.id_mecha), 
                        action.attack
                    );
                if mecha_distance > mecha_attributes.attack_shoot_distance {
                    return false;
                }
            },
        }
        true
    }

    fn is_valid_position(position: Position) -> bool {
        position.x > MAP_HEIGHT | position.y > MAP_WIDTH
    }

    fn distance(initial: Position, target: Position) -> u128 {
        let x = initial.x - target.x;
        let y = initial.y - target.y;
        let ret: felt252 = u128_sqrt(x * x + y * y).into();
        ret.try_into().unwrap()
    }

    fn validate_movement(initial_position: Position, candidate_position: Position, attributes: MechaAttributes) -> bool {
        if !is_valid_position(initial_position) & !is_valid_position(candidate_position) {
            return false;
        }

        return true;

    }

    fn load_initial_state(game_state: GameState) -> MechaDict {
        let mut mecha_dict = MechaDictTrait::new();
        _load_initial_state(game_state.players, 0, mecha_dict)
    }

    fn _load_initial_state(players: Span<PlayerState>, idx: usize, mut mecha_dict: MechaDict) -> MechaDict {
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
            mecha_dict.update_mecha_hp(mecha_state.id, mecha_state.hp);
            idy += 1;
        };
        _load_initial_state(players, idx + 1, mecha_dict)
    }

    fn load_static_data(game_state: GameState) -> MechaStaticData {
        let mut mecha_data = MechaStaticDataTrait::new();
        _load_static_data(game_state.players, 0, mecha_data, 1)
    }

    fn _load_static_data(players: Span<PlayerState>, idx: usize, mut mecha_data: MechaStaticData, mut mecha_spoof_id: u128) -> MechaStaticData {
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

    #[view]
    fn get_game(id_game: u128) -> Game {
        _game::read(id_game)
    }
}
