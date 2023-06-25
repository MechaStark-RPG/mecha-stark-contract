#[cfg(test)]
mod tests {
    use core::traits::Into;
    use core::result::ResultTrait;
    use array::ArrayTrait;
    use traits::TryInto;
    use option::OptionTrait;
    use starknet::class_hash::Felt252TryIntoClassHash;

    use mecha_stark::components::position::{Position, PositionTrait};

    #[test]
    #[available_gas(2000000)]
    fn happy_path() {
        let p1 = Position { x: 1, y: 1 };
        let p2 = Position { x: 2, y: 2 };
        assert(p1.distance(p2) == 2, 'Distance should be 1');
    }
}
