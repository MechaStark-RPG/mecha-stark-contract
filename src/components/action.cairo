use mecha_stark::components::position::{Position};
use mecha_stark::components::game::{MechaAttributes};
use mecha_stark::components::game_state::{MechaState};

#[derive(Copy, Drop, Serde)]
struct Action {
    id_game: u128,
    id_mecha: u128,
    first_action: u128,
    movement: Position,
    attack: Position,
}

trait ActionTrait {
    fn verify(self: @Action, mecha_state: MechaState) -> bool;
}

impl ActionTraitImpl of ActionTrait {

    fn verify(self: @Action, mecha_state: MechaState) -> bool {
        
        // Validaciones de cada jugada
        
        // assert(position_validate(action.movement) == true, '');
        // assert(position_validate(action.attack) == true, '');
            //position_validate
                // 1. validar que el casillero no esta fuera del mapa
                // 2. validar que el casillero no esta ocupado por un mecha aliado
                // 3. validar que el casillero no esta ocupado por un mecha enemigo

        // 2. validar que el mecha esta en el rango de ataque
        // assert(calculate_distance(action.attack) <= mecha.attack, '');

        // 3. validar que el mecha esta en el rango de movimiento
        // assert(calculate_distance(action.movement) <= mecha.mov, '');
    
        true
    }
}
