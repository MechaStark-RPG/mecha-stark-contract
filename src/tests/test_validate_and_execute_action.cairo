#[cfg(test)]
mod tests {
    use core::traits::Into;
    use core::result::ResultTrait;
    use array::ArrayTrait;
    use traits::TryInto;
    use option::OptionTrait;
    use starknet::class_hash::Felt252TryIntoClassHash;

    use mecha_stark::components::turn::{Action, ActionTrait, TypeAction, Turn};
    use mecha_stark::components::mecha_data_helper::{
        MechaDict, MechaDictTrait, MechaStaticData, MechaStaticDataTrait
    };
    use mecha_stark::components::game_state::{MechaState};
    use mecha_stark::components::position::{Position};
    use mecha_stark::components::game::{MechaAttributes};

    use mecha_stark::components::game_state_manager::validate_and_execute_action;

    #[test]
    #[available_gas(3000000000)]
    fn happy_path() {
        let mut mecha_dict = MechaDictTrait::new();
        let mut mecha_data = MechaStaticDataTrait::new();
        
        // Player 1 
        let mecha_state = MechaState {
            id: 1,
            position: Position { x: 0, y: 0 },
            hp: 100,
        };
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);

        let player_1 = starknet::contract_address_const::<1>();
        mecha_data.insert_mecha_data(player_1, MechaAttributes {
            id: 1,
            hp: 100,
            attack: 10,
            armor: 10,
            movement: 5,
            attack_shoot_distance: 10,
            attack_meele_distance: 2,
        });

        // Player 2 
        let mecha_state = MechaState {
            id: 2,
            position: Position { x: 5, y: 5 },
            hp: 100,
        };
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);

        let player_2 = starknet::contract_address_const::<2>();
        mecha_data.insert_mecha_data(player_2, MechaAttributes {
            id: 2,
            hp: 100,
            attack: 25,
            armor: 10,
            movement: 5,
            attack_shoot_distance: 4,
            attack_meele_distance: 2,
        });
        
        // Action 1

        let action = Action {
            id_mecha: 1, 
            first_action: TypeAction::Attack(()), 
            movement: Position { x: 1, y: 2 }, 
            attack: Position { x: 5, y: 5 } 
        };

        let validate = validate_and_execute_action(player_1, action, ref mecha_dict, ref mecha_data);
        assert(validate == true, '');

        // Player 1
        assert(mecha_dict.get_position_by_mecha_id(1) == Position { x: 1, y: 2 }, 'validate action');
        assert(mecha_dict.get_mecha_hp(1) == 100, 'validate action');

        // // Player 2
        assert(mecha_dict.get_position_by_mecha_id(2) == Position { x: 5, y: 5 }, 'validate action');
        assert(mecha_dict.get_mecha_hp(2) == 90, 'validate action');

        // Action 2
        let action = Action {
            id_mecha: 2, 
            first_action: TypeAction::Movement(()), 
            movement: Position { x: 3, y: 4 }, 
            attack: Position { x: 1, y: 2 } 
        };

        let validate = validate_and_execute_action(player_2, action, ref mecha_dict, ref mecha_data);
        assert(validate == true, '');

        // Player 1
        assert(mecha_dict.get_position_by_mecha_id(1) == Position { x: 1, y: 2 }, 'validate action');
        assert(mecha_dict.get_mecha_hp(1) == 75, 'validate action');

        // Player 2
        assert(mecha_dict.get_position_by_mecha_id(2) == Position { x: 3, y: 4 }, 'validate action');
        assert(mecha_dict.get_mecha_hp(2) == 90, 'validate action');
    }
}
