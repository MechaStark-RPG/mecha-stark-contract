use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
struct Game {
    id: u128,
    bet: u128,
    winner: ContractAddress,
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
