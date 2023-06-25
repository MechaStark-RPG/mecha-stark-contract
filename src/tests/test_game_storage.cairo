#[cfg(test)]
mod tests {
    use core::traits::Into;
    use core::result::ResultTrait;
    use starknet::syscalls::deploy_syscall;
    use array::{ArrayTrait, SpanTrait};
    use traits::TryInto;
    use option::OptionTrait;
    use starknet::class_hash::Felt252TryIntoClassHash;

    use mecha_stark::game_contract::{
        MechaStarkContract, IMechaStarkContractDispatcher, IMechaStarkContractDispatcherTrait
    };

    use mecha_stark::components::turn::{Action, ActionTrait, TypeAction, Turn};
    use mecha_stark::components::game::{Game, MechaAttributes};
    use mecha_stark::components::game_state::{GameState, MechaState};
    use mecha_stark::components::position::{Position};

    #[test]
    #[available_gas(300000000)]
    fn test_game_storage() {
        let mut calldata = ArrayTrait::new();
        calldata.append(100);
        let (contract_address, _) = deploy_syscall(
            MechaStarkContract::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();

        let contract0 = IMechaStarkContractDispatcher { contract_address };

        let mut mechas = ArrayTrait::new();
        mechas.append(923);
        mechas.append(123);
        mechas.append(3);
        mechas.append(4);
        mechas.append(5);

        let user = starknet::contract_address_const::<0>();
        contract0.create_game(mechas);

        let game_0 = contract0.get_game(0);

        assert(game_0.mechas_player_1.len() == 5, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_1.at(0) == 923, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_1.at(1) == 123, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_1.at(2) == 3, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_1.at(3) == 4, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_1.at(4) == 5, 'ERROR_SAVE_STORAGE');

        let mut mechas_2 = ArrayTrait::new();
        mechas_2.append(9);
        mechas_2.append(8);
        mechas_2.append(7);
        mechas_2.append(6);
        mechas_2.append(5);

        let user_2 = starknet::contract_address_const::<0>();
        contract0.join_game(0, mechas_2);

        let game_0 = contract0.get_game(0);

        assert(game_0.mechas_player_1.len() == 5, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_1.at(0) == 923, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_1.at(1) == 123, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_1.at(2) == 3, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_1.at(3) == 4, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_1.at(4) == 5, 'ERROR_SAVE_STORAGE');

        assert(game_0.mechas_player_2.len() == 5, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_2.at(0) == 9, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_2.at(1) == 8, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_2.at(2) == 7, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_2.at(3) == 6, 'ERROR_SAVE_STORAGE');
        assert(*game_0.mechas_player_2.at(4) == 5, 'ERROR_SAVE_STORAGE');
    }
}
