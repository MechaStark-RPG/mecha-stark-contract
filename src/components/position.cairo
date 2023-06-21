use integer::{U128IntoFelt252, Felt252TryIntoU128};
use option::OptionTrait;
use traits::{Into, TryInto};

use mecha_stark::utils::constants::Constants;

#[derive(Copy, Drop, Serde, ParcialEq)]
struct Position {
    x: u128,
    y: u128,
}

trait PositionTrait {
    fn distance(self: @Position, target: Position) -> u128;
}

impl PositionTraitImpl of PositionTrait {
    fn distance(self: @Position, target: Position) -> u128 {
        let x = *self.x - target.x;
        let y = *self.y - target.y;
        let ret: felt252 = u128_sqrt(x * x + y * y).into();
        ret.try_into().unwrap()
    }
}

impl PositionPartialEq of PartialEq<Position> {
    #[inline(always)]
    fn eq(lhs: Position, rhs: Position) -> bool {
        lhs.x == rhs.x & lhs.y == rhs.y
    }
    #[inline(always)]
    fn ne(lhs: Position, rhs: Position) -> bool {
        !(lhs == rhs)
    }
}

impl IntoU128ToPositionImpl of Into<Position, u128> {
    fn into(self: Position) -> u128 {
        self.y * Constants::BOARD_WIDTH + self.x
    }
}

impl IntoPositionToU128Impl of Into<u128, Position> {
    fn into(self: u128) -> Position {
        let y = self / Constants::BOARD_WIDTH;
        let x = self % Constants::BOARD_WIDTH;
        Position { x, y }
    }
}

impl IntoFelt252ToPositionImpl of Into<Position, felt252> {
    fn into(self: Position) -> felt252 {
        let self_u128: u128 = self.into();
        self_u128.into()
    }
}

impl IntoPositionToFelt252Impl of Into<felt252, Position> {
    fn into(self: felt252) -> Position {
        let self_u128: u128 = self.try_into().unwrap();
        self.into()
    }
}