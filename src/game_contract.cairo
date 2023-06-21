use mecha_stark::components::turn::{Turn};
use mecha_stark::components::game::{Game};
use mecha_stark::components::game_state::{GameState};

#[abi]
trait IMechaStarkContract {
    fn create_game(id_game: u128, new_game: Game);
    fn validate_game(game_state: GameState, turns: Array<Turn>);
    fn get_game(id_game: u128) -> Game;
}

#[contract]
mod MechaStarkContract {
    
    use array::{ArrayTrait, SpanTrait};
    use starknet::ContractAddress;

    use mecha_stark::components::turn::{Action, ActionTrait, TypeAction, Turn};
    use mecha_stark::components::game::{Game, MechaAttributes};
    use mecha_stark::components::game_state::{GameState, PlayerState, MechaState};
    use mecha_stark::components::position::{Position};
    use mecha_stark::components::mecha_data_helper::{MechaDict, MechaDictTrait, MechaStaticData, MechaStaticDataTrait};
    use mecha_stark::utils::storage::{GameStorageAccess};
    use mecha_stark::utils::serde::{SpanSerde};
    
    use super::IMechaStarkContract;

    struct Storage {
        _count_games: u128,
        _owner: ContractAddress,
        _token: ContractAddress,
        _game: LegacyMap::<u128, Game>,
        _players: LegacyMap::<(u128, ContractAddress), ContractAddress>,
        _mechas_ids: LegacyMap::<(u128, ContractAddress), ContractAddress>,
    }

    #[external]
    fn create_game(id_game: u128, new_game: Game) {
        _game::write(id_game, new_game);
    }

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
                if !validate_and_execute_action(player, action, ref mecha_dict, ref mecha_static_data) {
                    // HIZO TRAMPA
                    break ();
                }

                // if is_game_finished(player, ref mecha_dict, ref mecha_static_data) {
                //     // TERMINO EL JUEGO
                //     // Guardar el estado final
                // }

                idy += 1;
            };
            idx += 1;
        }
    }

    #[view]
    fn get_game(id_game: u128) -> Game {
        _game::read(id_game)
    }

    fn validate_and_execute_action(player: ContractAddress, action: Action, ref mecha_dict: MechaDict, ref mecha_static_data: MechaStaticData) -> bool {
        match action.first_action {
            TypeAction::Movement(()) => {
                if !action.validate_movement(player, ref mecha_dict, ref mecha_static_data) {
                    return false;
                }
                mecha_dict.update_mecha_position(action.id_mecha, action.movement);
                
                if !action.validate_attack(player, ref mecha_dict, ref mecha_static_data) {
                    return false;
                }
                mecha_dict.update_mecha_hp(action.id_mecha, action.attack, ref mecha_static_data);
            },
            TypeAction::Attack(()) => {
                if !action.validate_attack(player, ref mecha_dict, ref mecha_static_data) {
                    return false;
                }
                mecha_dict.update_mecha_hp(action.id_mecha, action.attack, ref mecha_static_data);
                
                if !action.validate_movement(player, ref mecha_dict, ref mecha_static_data) {
                    return false;
                }
                mecha_dict.update_mecha_position(action.id_mecha, action.movement);
            },
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
            mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);
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
}
