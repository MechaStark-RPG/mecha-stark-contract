#[cfg(test)]
mod tests {
    use core::traits::Into;
    use core::result::ResultTrait;
    use starknet::syscalls::deploy_syscall;
    use array::{ArrayTrait, SpanTrait};
    use traits::TryInto;
    use option::OptionTrait;
    use starknet::class_hash::Felt252TryIntoClassHash;
    
    use mecha_stark::game::game::{MechaStarkContract, IMechaStarkContractDispatcher, IMechaStarkContractDispatcherTrait};
    use mecha_stark::game::entities::{Action, Game, Position};
    use mecha_stark::game::storage::{GameStorageAccess};
    use mecha_stark::game::serde::{SpanSerde};

    #[test]
    #[available_gas(3000000000)]
    fn test_flow() {
        let mut calldata = ArrayTrait::new();
        calldata.append(100);
        let (contract_address, _) = deploy_syscall(
            MechaStarkContract::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        ).unwrap();

        let contract0 = IMechaStarkContractDispatcher { contract_address };


        let turn_id = 1;
        let current_player_turn = starknet::contract_address_const::<10>();
        let winner = starknet::contract_address_const::<10>();
        let map_id = 15;
        let mut mechas_ids = ArrayTrait::<felt252>::new();
        mechas_ids.append(1);
        mechas_ids.append(2);
        mechas_ids.append(3);

        let mut players = ArrayTrait::<felt252>::new();
        players.append(10);
        players.append(11);

        let game = Game {
            turn_id,
            current_player_turn,
            winner,
            map_id,
            mechas_ids: mechas_ids.span(),
            players: players.span()
        };

        contract0.create_game(1, game); 
        
        let result = contract0.get_game(1);
        assert(result.turn_id == 1, 'error test legacy map ');
        assert(result.current_player_turn == current_player_turn, 'error test legacy map ');
        // assert(result.winner == winner, 'error test legacy map ');
        assert(result.map_id == map_id, 'error test legacy map ');
        // assert(result. == , 'error test legacy map ');
    }
}
