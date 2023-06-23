use starknet::ContractAddress;
use mecha_stark::utils::serde::{SpanSerde};

#[derive(Copy, Drop, Serde)]
struct Game {
    size: u128,
    bet: u128,
    winner: ContractAddress,
    player_1: ContractAddress,
    player_2: ContractAddress,
    mechas_player_1: Span<felt252>,
    mechas_player_2: Span<felt252>,
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

#[derive(Copy, Drop, Serde)]
struct Map {
    id: u128,
    width: u128,
    height: u128,
}

trait MechaAttributesTrait {
    fn new() -> MechaAttributes;
}

impl MechaAttributesImpl of MechaAttributesTrait {
    fn new() -> MechaAttributes {
        MechaAttributes {
            id: 0,
            hp: 0,
            attack: 0,
            armor: 0,
            movement: 0,
            attack_shoot_distance: 0,
            attack_meele_distance: 0,
        }
    }
}
