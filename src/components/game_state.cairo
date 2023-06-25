use starknet::ContractAddress;

use mecha_stark::components::position::{Position};
use mecha_stark::utils::serde::{SpanSerde};

#[derive(Copy, Drop, Serde)]
struct GameState {
    id_game: u128,
    player_1: ContractAddress,
    player_2: ContractAddress,
    mechas_state_player_1: Span<MechaState>,
    mechas_state_player_2: Span<MechaState>,
}

#[derive(Copy, Drop, Serde)]
struct MechaState {
    id: u128,
    hp: u128,
    position: Position,
}
