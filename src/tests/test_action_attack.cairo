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

    #[test]
    #[available_gas(2000000)]
    fn happy_path() {
        let mut mecha_dict = MechaDictTrait::new();
        let mut mecha_data = MechaStaticDataTrait::new();

        // Player 1 
        let mecha_state = MechaState { id: 1, position: Position { x: 0, y: 0 }, hp: 100,  };
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);

        let player_1 = starknet::contract_address_const::<1>();
        mecha_data
            .insert_mecha_data(
                player_1,
                MechaAttributes {
                    id: 1,
                    hp: 100,
                    attack: 10,
                    armor: 10,
                    movement: 5,
                    attack_shoot_distance: 10,
                    attack_meele_distance: 2,
                }
            );

        // Player 2 
        let mecha_state = MechaState { id: 2, position: Position { x: 5, y: 5 }, hp: 100,  };
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);

        let player_2 = starknet::contract_address_const::<2>();
        mecha_data
            .insert_mecha_data(
                player_2,
                MechaAttributes {
                    id: 2,
                    hp: 100,
                    attack: 10,
                    armor: 10,
                    movement: 5,
                    attack_shoot_distance: 4,
                    attack_meele_distance: 2,
                }
            );

        let action = Action {
            mecha_id: 1, first_action: TypeAction::Attack(()), movement: Position {
                x: 1, y: 2
                }, attack: Position {
                x: 5, y: 5
            }
        };
        assert(
            action.validate_attack(player_1, ref mecha_dict, ref mecha_data) == true,
            'INVALID_ATTACK'
        );
    }

    #[test]
    #[available_gas(2000000)]
    fn attack_inside_the_map() {
        let mut mecha_dict = MechaDictTrait::new();
        let mut mecha_data = MechaStaticDataTrait::new();

        // Player 1 
        let mecha_state = MechaState { id: 1, position: Position { x: 0, y: 0 }, hp: 100,  };
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);

        let player_1 = starknet::contract_address_const::<1>();
        mecha_data
            .insert_mecha_data(
                player_1,
                MechaAttributes {
                    id: 1,
                    hp: 100,
                    attack: 10,
                    armor: 10,
                    movement: 5,
                    attack_shoot_distance: 4,
                    attack_meele_distance: 2,
                }
            );

        let action = Action {
            mecha_id: 1, first_action: TypeAction::Attack(()), movement: Position {
                x: 1, y: 2
                }, attack: Position {
                x: 30, y: 5
            }
        };

        assert(
            action.validate_attack(player_1, ref mecha_dict, ref mecha_data) == false,
            'INVALID_ATTACK'
        );
    }

    #[test]
    #[available_gas(2000000)]
    fn within_attack_range() {
        let mut mecha_dict = MechaDictTrait::new();
        let mut mecha_data = MechaStaticDataTrait::new();

        // Player 1 
        let mecha_state = MechaState { id: 1, position: Position { x: 0, y: 0 }, hp: 100,  };
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);

        let player_1 = starknet::contract_address_const::<1>();
        mecha_data
            .insert_mecha_data(
                player_1,
                MechaAttributes {
                    id: 1,
                    hp: 100,
                    attack: 10,
                    armor: 10,
                    movement: 5,
                    attack_shoot_distance: 5,
                    attack_meele_distance: 2,
                }
            );

        // Player 2 
        let mecha_state = MechaState { id: 2, position: Position { x: 3, y: 3 }, hp: 100,  };
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);

        let player_2 = starknet::contract_address_const::<2>();
        mecha_data
            .insert_mecha_data(
                player_2,
                MechaAttributes {
                    id: 2,
                    hp: 100,
                    attack: 10,
                    armor: 10,
                    movement: 5,
                    attack_shoot_distance: 4,
                    attack_meele_distance: 2,
                }
            );

        let action = Action {
            mecha_id: 1, first_action: TypeAction::Attack(()), movement: Position {
                x: 1, y: 2
                }, attack: Position {
                x: 3, y: 3
            }
        };
        assert(
            action.validate_attack(player_1, ref mecha_dict, ref mecha_data) == false,
            'INVALID_ATTACK'
        );
    }

    #[test]
    #[available_gas(2000000)]
    fn attack_empty_position() {
        let mut mecha_dict = MechaDictTrait::new();
        let mut mecha_data = MechaStaticDataTrait::new();

        // Player 1 
        let mecha_state = MechaState { id: 1, position: Position { x: 0, y: 0 }, hp: 100,  };
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);

        let player_1 = starknet::contract_address_const::<1>();
        mecha_data
            .insert_mecha_data(
                player_1,
                MechaAttributes {
                    id: 1,
                    hp: 100,
                    attack: 10,
                    armor: 10,
                    movement: 5,
                    attack_shoot_distance: 10,
                    attack_meele_distance: 2,
                }
            );

        // Player 2 
        let mecha_state = MechaState { id: 2, position: Position { x: 5, y: 5 }, hp: 100,  };
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);

        let player_2 = starknet::contract_address_const::<2>();
        mecha_data
            .insert_mecha_data(
                player_2,
                MechaAttributes {
                    id: 2,
                    hp: 100,
                    attack: 10,
                    armor: 10,
                    movement: 5,
                    attack_shoot_distance: 4,
                    attack_meele_distance: 2,
                }
            );

        let action = Action {
            mecha_id: 1, first_action: TypeAction::Attack(()), movement: Position {
                x: 1, y: 2
                }, attack: Position {
                x: 3, y: 3
            }
        };
        assert(
            action.validate_attack(player_1, ref mecha_dict, ref mecha_data) == false,
            'INVALID_ATTACK'
        );
    }

    #[test]
    #[available_gas(2000000)]
    fn attack_myself() {
        let mut mecha_dict = MechaDictTrait::new();
        let mut mecha_data = MechaStaticDataTrait::new();

        // Player 1 
        let mecha_state = MechaState { id: 1, position: Position { x: 0, y: 0 }, hp: 100,  };
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);

        let player_1 = starknet::contract_address_const::<1>();
        mecha_data
            .insert_mecha_data(
                player_1,
                MechaAttributes {
                    id: 1,
                    hp: 100,
                    attack: 10,
                    armor: 10,
                    movement: 5,
                    attack_shoot_distance: 10,
                    attack_meele_distance: 2,
                }
            );

        // Player 2 
        let mecha_state = MechaState { id: 2, position: Position { x: 5, y: 5 }, hp: 100,  };
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);

        mecha_data
            .insert_mecha_data(
                player_1,
                MechaAttributes {
                    id: 2,
                    hp: 100,
                    attack: 10,
                    armor: 10,
                    movement: 5,
                    attack_shoot_distance: 4,
                    attack_meele_distance: 2,
                }
            );

        let action = Action {
            mecha_id: 1, first_action: TypeAction::Attack(()), movement: Position {
                x: 1, y: 2
                }, attack: Position {
                x: 5, y: 5
            }
        };
        assert(
            action.validate_attack(player_1, ref mecha_dict, ref mecha_data) == false,
            'INVALID_ATTACK'
        );
    }

    #[test]
    #[available_gas(2000000)]
    fn rival_dead() {
        let mut mecha_dict = MechaDictTrait::new();
        let mut mecha_data = MechaStaticDataTrait::new();

        // Player 1 
        let mecha_state = MechaState { id: 1, position: Position { x: 0, y: 0 }, hp: 100,  };
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);

        let player_1 = starknet::contract_address_const::<1>();
        mecha_data
            .insert_mecha_data(
                player_1,
                MechaAttributes {
                    id: 1,
                    hp: 100,
                    attack: 10,
                    armor: 10,
                    movement: 5,
                    attack_shoot_distance: 10,
                    attack_meele_distance: 2,
                }
            );

        // Player 2 
        let mecha_state = MechaState { id: 2, position: Position { x: 5, y: 5 }, hp: 0,  };
        mecha_dict.update_mecha_position(mecha_state.id, mecha_state.position);
        mecha_dict.set_mecha_hp(mecha_state.id, mecha_state.hp);

        let player_2 = starknet::contract_address_const::<2>();
        mecha_data
            .insert_mecha_data(
                player_2,
                MechaAttributes {
                    id: 2,
                    hp: 100,
                    attack: 10,
                    armor: 10,
                    movement: 5,
                    attack_shoot_distance: 4,
                    attack_meele_distance: 2,
                }
            );

        let action = Action {
            mecha_id: 1, first_action: TypeAction::Attack(()), movement: Position {
                x: 1, y: 2
                }, attack: Position {
                x: 5, y: 5
            }
        };
        assert(
            action.validate_attack(player_1, ref mecha_dict, ref mecha_data) == false,
            'INVALID_ATTACK'
        );
    }
}
