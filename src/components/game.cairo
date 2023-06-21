use starknet::ContractAddress;
use mecha_stark::serde::{SpanSerde};

#[derive(Copy, Drop, Serde)]
struct Game {
    turn_id: u128,
    current_player_turn: ContractAddress,
    winner: ContractAddress,
    map_id: u128,
    mechas_ids: Span<felt252>,
    players: Span<felt252>,
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
