use starknet::ContractAddress;
use mecha_stark::components::position::{Position};
use mecha_stark::serde::{SpanSerde};


#[derive(Copy, Drop, Serde)]
struct GameState {
    id_game: u128,
    players: Span<PlayerState>,
}

#[derive(Copy, Drop, Serde)]
struct PlayerState {
    owner: ContractAddress,
    mechas: Span<MechaState>,
}

#[derive(Copy, Drop, Serde)]
struct MechaState {
    id: u128,
    hp: u128,
    position: Position,
}

trait MechaStateTrait {
    fn new() -> MechaState;
}

impl MechaStateImpl of MechaStateTrait {
    fn new() -> MechaState {
        MechaState { 
            id: 0,
            hp: 0,
            position: Position { x: 0, y: 0 }
        }
    }
}