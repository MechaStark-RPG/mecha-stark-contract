use mecha_stark::components::game::{Map};
use integer::{U128IntoFelt252, Felt252TryIntoU128};
use traits::{Into, TryInto};
use option::OptionTrait;

const BOARD_WIDTH: u128 = 30;
const BOARD_HEIGHT: u128 = 14;

const BOARD_WIDTH_FELT: felt252 = 30;
const BOARD_HEIGHT_FELT: felt252 = 14;

#[derive(Copy, Drop, Serde, ParcialEq)]
struct Position {
    x: u128,
    y: u128,
}

trait PositionTrait {
    fn validate(self: @Position, map: Map) -> bool;
}

impl PositionTraitImpl of PositionTrait {
    fn validate(self: @Position, map: Map) -> bool {
        *self.x < map.width & *self.y < map.height
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
        self.y * BOARD_WIDTH + self.x
    }
}

impl IntoPositionToU128Impl of Into<u128, Position> {
    fn into(self: u128) -> Position {
        let y = self / BOARD_WIDTH;
        let x = self % BOARD_WIDTH;
        Position { x, y }
    }
}

impl IntoFelt252ToPositionImpl of Into<Position, felt252> {
    fn into(self: Position) -> felt252 {
        self.y.into() * BOARD_WIDTH_FELT + self.x.into()
    }
}

impl IntoPositionToFelt252Impl of Into<felt252, Position> {
    fn into(self: felt252) -> Position {
        let self_u128: u128 = self.try_into().unwrap();
        let y: u128 = (self_u128 / BOARD_WIDTH);
        let x: u128 = (self_u128 % BOARD_WIDTH);
        Position { x, y }
    }
}