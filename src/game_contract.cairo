use mecha_stark::components::action::{Action, ActionTrait};
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

    use mecha_stark::components::action::{Action, ActionTrait};
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
    fn validate_game(game_state: GameState, actions: Array<Action>) {        
        let mut mecha_dict = load_initial_state(game_state);
        let mut mecha_static_data = load_static_data(game_state);

        // bool valiteActions()
        // if is_valid_action -> update_game_data()
        // Iterar acciones
        let mut idx = 0;
        loop {
            if idx == actions.len() {
                break ();
            }
            let action = *actions.at(idx);
            let is_valid_action = validate_action(action, ref mecha_dict, ref mecha_static_data);

            // validar que el casillero no esta fuera del mapa

            // validar que el casillero no esta ocupado

            // Tengo que obtener el mecha con sus atributos
            // Dado el orden hay que validar 
            // validar que el mecha esta en el rango de ataque
            // validar que el mecha esta en el rango de movimiento


            // let mecha_attacker = map_ocuppied.get(action.mecha_id.into());
            // let mecha_receiver = map_mecha_for_position(position_to_map(action.attack));
            
            // Validar que existan y esten vivos
            

            // Actualizar el estado del juego
            
            // Ver si el juego termino

            idx += 1;
        }
    }

    fn validate_action(action: Action, ref mecha_dict: MechaDict, ref mecha_static_data: MechaStaticData) -> bool {
        // cual es el primer movimiento? 
        // if first_movement == 1 {
        // A y B 
        // else
        // B y A
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
            mov: 5,
            attack_shoot_distance: 4,
            attack_meele_distance: 2,
        }
    }

    #[view]
    fn get_game(id_game: u128) -> Game {
        _game::read(id_game)
    }
}
