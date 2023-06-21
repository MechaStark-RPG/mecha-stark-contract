use traits::{Into, TryInto};
use starknet::ContractAddress;

use mecha_stark::components::game::{MechaAttributes, MechaAttributesTrait};
use mecha_stark::components::game_state::{MechaState, MechaStateTrait};
use mecha_stark::components::mecha_data_helper::{
    MechaDict, MechaDictTrait, MechaStaticData, MechaStaticDataTrait
};
use mecha_stark::components::position::{Position, PositionTrait};
use mecha_stark::utils::constants::Constants;
use mecha_stark::utils::serde::{SpanSerde};

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

trait ActionTrait {
    fn validate_attack(
        self: @Action,
        player: ContractAddress,
        ref mecha_dict: MechaDict,
        ref mecha_static_data: MechaStaticData
    ) -> bool;
    fn validate_movement(
        self: @Action,
        player: ContractAddress,
        ref mecha_dict: MechaDict,
        ref mecha_static_data: MechaStaticData
    ) -> bool;
}

impl ActionTraitImpl of ActionTrait {
    fn validate_attack(
        self: @Action,
        player: ContractAddress,
        ref mecha_dict: MechaDict,
        ref mecha_static_data: MechaStaticData
    ) -> bool {

        // Donde ataco dentro del mapa
        if !position_within_the_map(*self.attack) {
            return false;
        }

        // Esta dentro del rango de ataque
        let (_, mecha_attributes) = mecha_static_data.get_mecha_data_by_mecha_id(*self.id_mecha);
        let mecha_distance = mecha_dict
            .get_position_by_mecha_id(*self.id_mecha)
            .distance(*self.attack);
        if mecha_distance > mecha_attributes.attack_shoot_distance {
            return false;
        }

        // Hay un mecha enemigo en esa posicion
        let mecha_id_received = mecha_dict.get_mecha_id_by_position(*self.attack.into());
        if mecha_id_received == 0 {
            return false;
        }
        let (owner_received, _) = mecha_static_data.get_mecha_data_by_mecha_id(mecha_id_received);
        if owner_received == player {
            return false;
        }
        let mecha_id_received_hp = mecha_dict.get_mecha_hp(mecha_id_received);
        if mecha_id_received_hp == 0 {
            return false;
        }

        true
    }

    fn validate_movement(
        self: @Action,
        player: ContractAddress,
        ref mecha_dict: MechaDict,
        ref mecha_static_data: MechaStaticData
    ) -> bool {

        if !position_within_the_map(*self.movement) {
            return false;
        }

        if mecha_dict.get_mecha_id_by_position(*self.movement.into()) == 0 {
            return false;
        }

        let (_, mecha_attributes) = mecha_static_data.get_mecha_data_by_mecha_id(*self.id_mecha);
        let mecha_distance = mecha_dict
            .get_position_by_mecha_id(*self.id_mecha)
            .distance(*self.movement);
        if mecha_distance > mecha_attributes.movement {
            return false;
        }
        true
    }
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

fn position_within_the_map(position: Position) -> bool {
    position.x < Constants::BOARD_HEIGHT & position.y < Constants::BOARD_WIDTH
}
