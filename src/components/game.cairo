use starknet::ContractAddress;
use mecha_stark::utils::serde::{SpanSerde};

#[derive(Copy, Drop, Serde)]
struct Game {
    size: u128,
    bet: u128,
    status: StatusGame,
    winner: ContractAddress,
    player_1: ContractAddress,
    player_2: ContractAddress,
    mechas_player_1: Span<felt252>,
    mechas_player_2: Span<felt252>,
}

#[derive(Copy, Drop, Serde)]
enum StatusGame {
    Waiting: (),
    Progress: (),
    Finished: (),
}

impl IntoFelt252StatusGameImpl of Into<StatusGame, felt252> {
    fn into(self: StatusGame) -> felt252 {
        match self {
            StatusGame::Waiting(()) => 0,
            StatusGame::Progress(()) => 1,
            StatusGame::Finished(()) => 2,
        }
    }
}

impl IntoStatusGameFelt252Impl of Into<felt252, StatusGame> {
    fn into(self: felt252) -> StatusGame {
        if self == 0 {
            return StatusGame::Waiting(());
        } else if self == 1 {
            return StatusGame::Progress(());
        }
        StatusGame::Finished(())
    }
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
