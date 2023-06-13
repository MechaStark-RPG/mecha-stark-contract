use starknet::ContractAddress;

struct Action {
    id: u128,
    player: ContractAddress,
    mecha: MechaAttributes,
    action_type: ActionType,
}

struct MechaAttributes {
    id: u128,
    hp: u128,
    attack: u128,
    armor: u128,
    mov: u128,
    attack_shoot_distance: u128,
    attack_meele_distance: u128,
}

struct MechaState {
    id: u128,
    hp: u128,
    position: Position,
}

enum ActionType { 
    Attack: (Position, Position), 
    Move: (Position, Position), 
}

struct Map {
    squares: Array<Square>,
}

struct Square {
    position: Position,
    terrain_type: u32,
    occupied: bool,
}

struct Position {
    x: u32,
    y: u32,
}