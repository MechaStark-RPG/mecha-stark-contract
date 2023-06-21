use array::ArrayTrait;
use dict::Felt252DictTrait;
use traits::{Into, TryInto};
use starknet::ContractAddress;

use mecha_stark::components::game::{MechaAttributes, MechaAttributesTrait};
use mecha_stark::components::game_state::{MechaState, MechaStateTrait};
use mecha_stark::components::position::{
    Position, IntoU128ToPositionImpl, IntoPositionToU128Impl, IntoFelt252ToPositionImpl,
    IntoPositionToFelt252Impl, PositionPartialEq
};

#[derive(Drop)]
struct MechaStaticData {
    owners: Array<ContractAddress>,
    attributes: Array<MechaAttributes>,
}

#[derive(Destruct)]
struct MechaDict {
    mechas_for_positions: Felt252Dict<u128>,
    positions_for_mechas: Felt252Dict<u128>,
    hp: Felt252Dict<u128>,
}

trait MechaDictTrait {
    fn new() -> MechaDict;
    fn get_mecha_id_by_position(ref self: MechaDict, position: Position) -> u128;
    fn get_position_by_mecha_id(ref self: MechaDict, mecha_id: u128) -> Position;
    fn get_mecha_hp(ref self: MechaDict, mecha_id: u128) -> u128;
    fn update_mecha_position(ref self: MechaDict, mecha_id: u128, position: Position);
    fn update_mecha_hp(
        ref self: MechaDict,
        id_mecha: u128,
        position_attack: Position,
        ref mecha_static_data: MechaStaticData
    );
    fn set_mecha_hp(ref self: MechaDict, id_mecha: u128, hp: u128);
}

impl MechaDictTraitImpl of MechaDictTrait {
    fn new() -> MechaDict {
        let mechas_for_positions = Felt252DictTrait::<u128>::new();
        let positions_for_mechas = Felt252DictTrait::<u128>::new();
        let hp = Felt252DictTrait::<u128>::new();
        MechaDict { mechas_for_positions, positions_for_mechas, hp,  }
    }

    fn get_mecha_id_by_position(ref self: MechaDict, position: Position) -> u128 {
        let mecha_id = self.mechas_for_positions.get(position.into());
        if mecha_id == 0 {
            panic_with_felt252('Mecha data - Invalid position');
        }
        mecha_id
    }

    fn get_position_by_mecha_id(ref self: MechaDict, mecha_id: u128) -> Position {
        let position = self.positions_for_mechas.get(mecha_id.into());
        if position == 0 {
            panic_with_felt252('Mecha data - Invalid mecha id');
        }
        position.into()
    }

    fn get_mecha_hp(ref self: MechaDict, mecha_id: u128) -> u128 {
        self.hp.get(mecha_id.into())
    }

    fn update_mecha_position(ref self: MechaDict, mecha_id: u128, position: Position) {
        self.mechas_for_positions.insert(position.into(), mecha_id);
        self.positions_for_mechas.insert(mecha_id.into(), position.into());
    }

    fn set_mecha_hp(ref self: MechaDict, id_mecha: u128, hp: u128) {
        self.hp.insert(id_mecha.into(), hp);
    }

    fn update_mecha_hp(
        ref self: MechaDict,
        id_mecha: u128,
        position_attack: Position,
        ref mecha_static_data: MechaStaticData
    ) {
        let (_, mecha_attack) = mecha_static_data.get_mecha_data_by_mecha_id(id_mecha);
        let mecha_received_id = self.get_mecha_id_by_position(position_attack);
        if mecha_received_id > 0 {
            let mecha_received_hp = self.get_mecha_hp(mecha_received_id);
            // fijarse que no se pase a negativo
            self.hp.insert(mecha_received_id.into(), mecha_received_hp - mecha_attack.attack);
        }
    }
}

trait MechaStaticDataTrait {
    fn new() -> MechaStaticData;
    fn get_mecha_data_by_mecha_id(
        self: @MechaStaticData, mecha_id: u128
    ) -> (ContractAddress, MechaAttributes);
    fn get_mechas_ids_by_owner(self: @MechaStaticData, owner: ContractAddress) -> Array<u128>;
    fn insert_mecha_data(
        ref self: MechaStaticData, owner: ContractAddress, attributes: MechaAttributes
    );
}

impl MechaStaticDataImpl of MechaStaticDataTrait {
    fn new() -> MechaStaticData {
        let mut owners: Array<ContractAddress> = ArrayTrait::new();
        let mut attributes: Array<MechaAttributes> = ArrayTrait::new();
        MechaStaticData { owners, attributes,  }
    }

    fn get_mecha_data_by_mecha_id(
        self: @MechaStaticData, mecha_id: u128
    ) -> (ContractAddress, MechaAttributes) {
        _get_mecha_data_by_mecha_id(self, mecha_id, 0)
    }

    fn get_mechas_ids_by_owner(self: @MechaStaticData, owner: ContractAddress) -> Array<u128> {
        let mut mechas: Array<u128> = ArrayTrait::new();
        _get_mechas_by_owner(self, owner, 0, mechas)
    }

    fn insert_mecha_data(
        ref self: MechaStaticData, owner: ContractAddress, attributes: MechaAttributes
    ) {
        self.owners.append(owner);
        self.attributes.append(attributes);
    }
}

fn _get_mechas_by_owner(
    mecha_data: @MechaStaticData, owner: ContractAddress, idx: usize, mut mechas: Array<u128>
) -> Array<u128> {
    if idx == mecha_data.owners.len() {
        return mechas;
    }

    let mecha_owner = *mecha_data.owners.at(idx);
    if mecha_owner == owner {
        let attribute = *mecha_data.attributes.at(idx);
        mechas.append(attribute.id);
    }
    _get_mechas_by_owner(mecha_data, owner, idx + 1, mechas)
}

fn _get_mecha_data_by_mecha_id(
    mecha_data: @MechaStaticData, mecha_id: u128, idx: usize
) -> (ContractAddress, MechaAttributes) {
    if idx == mecha_data.owners.len() {
        panic_with_felt252('Mecha data - Invalid mecha id');
    }

    let mecha_attributes = *mecha_data.attributes.at(idx);
    if mecha_attributes.id == mecha_id {
        return (*mecha_data.owners.at(idx), mecha_attributes);
    }

    _get_mecha_data_by_mecha_id(mecha_data, mecha_id, idx + 1)
}
