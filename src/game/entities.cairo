use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
struct Action {
    id_mecha: u128,
    first_action: u128,
    movement: Position,
    attack: Position,
}

#[derive(Copy, Drop, Serde)]
struct Position {
    x: u32,
    y: u32,
}

#[derive(Copy, Drop, Serde)]
struct Game {
    turn_id: u128,
    current_player_turn: ContractAddress,
    winner: ContractAddress,
    map_id: u128,
    // mechas_ids: Span<u128>,
    // players: Span<ContractAddress>,
}
