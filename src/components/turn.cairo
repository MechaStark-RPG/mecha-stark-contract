use mecha_stark::components::position::{Position};
use mecha_stark::serde::{SpanSerde};
use starknet::ContractAddress;

#[derive(Drop, Serde)]
struct Turn {
    id_game: u128,
    player: ContractAddress,
    actions: Span<Action>,
}

#[derive(Copy, Drop, Serde)]
struct Action {
    id_mecha: u128,
    first_action: TypeAction,
    movement: Position,
    attack: Position,
}

#[derive(Copy, Drop, Serde)]
enum TypeAction {
    Movement: (),
    Attack: (),
}

impl IntoFelt252ActionImpl of Into<TypeAction, felt252> {
    fn into(self: TypeAction) -> felt252 {
        match self {
            TypeAction::Movement(()) => 0,
            TypeAction::Attack(()) => 1,
        }
    }
}

impl IntoActionFelt252Impl of Into<felt252, TypeAction> {
    fn into(self: felt252) -> TypeAction {
        if (self == 0) {
            return TypeAction::Movement(());
        }
        TypeAction::Attack(())
    }
}

