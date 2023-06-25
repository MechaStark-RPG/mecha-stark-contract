use starknet::ContractAddress;
use mecha_stark::utils::serde::{SpanSerde};

#[derive(Copy, Drop, Serde)]
struct Game {
    size: u128,
    bet: u128,
    status: u8,
    winner: ContractAddress,
    player_1: ContractAddress,
    player_2: ContractAddress,
    mechas_player_1: Span<felt252>,
    mechas_player_2: Span<felt252>,
}

#[derive(Copy, Drop, Serde)]
enum GameStatus {
    Winner1: (),
    Winner2: (),
    Cheater1: (),
    Cheater2: (),
}

#[derive(Copy, Drop, Serde)]
struct MechaAttributes {
    id: u128,
    hp: u128,
    attack: u128,
    armor: u128,
    movement: u128,
    attack_shoot_distance: u128,
    attack_meele_distance: u128,
}
