use mecha_stark::components::game::{Game};
use mecha_stark::components::position::{Position};
use mecha_stark::components::turn::{Action, TypeAction, Turn};
use mecha_stark::components::game_state::{GameState, MechaState};

use starknet::{ContractAddress, ClassHash};

#[abi]
trait IMechaStarkContract {
    #[external]
    fn create_game(mechas_id: Array<felt252>);
    #[external]
    fn join_game(game_id: u128, mechas_id: Array<felt252>);
    #[view]
    fn validate_game(game_state: GameState, turns: Array<Turn>) -> bool;
    #[external]
    fn finish_game(game_id: u128, game_state: GameState, turns: Array<Turn>);
    #[view]
    fn get_game(game_id: u128) -> Game;
    #[external]
    fn upgrade(new_class_hash: ClassHash);
    #[view]
    fn nothing(position: Position, action: Action, game_state: GameState, mecha_state: MechaState) -> u128;
}

#[contract]
mod MechaStarkContract {
    use array::{ArrayTrait, SpanTrait};
    use starknet::{
        ContractAddress, ClassHash, get_caller_address, get_contract_address, replace_class_syscall
    };
    use traits::{Into, TryInto};

    use mecha_stark::components::turn::{Action, ActionTrait, TypeAction, Turn};
    use mecha_stark::components::game::{Game, GameResult, MechaAttributes};
    use mecha_stark::components::game_state::{GameState, MechaState};
    use mecha_stark::components::game_state_manager::_validate_game;
    use mecha_stark::components::position::{Position, PositionTrait};
    use mecha_stark::components::mecha_data_helper::{
        MechaDict, MechaDictTrait, MechaStaticData, MechaStaticDataTrait
    };
    use mecha_stark::utils::constants::Constants;
    use mecha_stark::utils::storage::{GameStorageAccess};
    use mecha_stark::utils::serde::{SpanSerde};

    struct Storage {
        _owner: ContractAddress,
        _token: ContractAddress,
        _count_games: u128,
        _games: LegacyMap<u128, Game>,
        _balances: LegacyMap<ContractAddress, u256>
    }

    #[constructor]
    fn constructor(token: ContractAddress) {
        _owner::write(get_caller_address());
        _token::write(token);
        _count_games::write(0);
    }

    #[external]
    fn create_game(mechas_id: Array<felt252>) {
        assert(mechas_id.len() == 5, 'game_contract: INVALID_LENGTH');

        // validate mechas for owner

        let player_address = get_caller_address();
        _games::write(
            _count_games::read(),
            Game {
                status: Constants::WAITING_FOR_PLAYER,
                winner: starknet::contract_address_const::<0>(),
                player_1: player_address,
                player_2: starknet::contract_address_const::<0>(),
                mechas_player_1: mechas_id.span(),
                mechas_player_2: ArrayTrait::new().span(),
            }
        );

        _count_games::write(_count_games::read() + 1);
    }

    #[external]
    fn join_game(game_id: u128, mechas_id: Array<felt252>) {
        assert(mechas_id.len() == 5, 'game_contract: INVALID_LENGTH');

        // validate mechas for owner

        let game = _games::read(game_id);
        assert(game.status == Constants::WAITING_FOR_PLAYER, 'game_contract: INVALID_STATUS');

        let player_address = get_caller_address();
        _games::write(
            game_id,
            Game {
                status: Constants::IN_PROGRESS,
                winner: game.winner,
                player_1: game.player_1,
                player_2: player_address,
                mechas_player_1: game.mechas_player_1,
                mechas_player_2: mechas_id.span(),
            }
        );
    }

    #[view]
    fn validate_game(game_state: GameState, turns: Array<Turn>) -> bool {
        match _validate_game(game_state, turns) {
            GameResult::Winner1(()) => true,
            GameResult::Winner2(()) => true,
            GameResult::Cheater1(()) => false,
            GameResult::Cheater2(()) => false,
        }
    }

    #[external]
    fn finish_game(game_id: u128, game_state: GameState, turns: Array<Turn>) {
        assert_only_owner();
        
        let game = _games::read(game_id);
        assert(game.status == Constants::IN_PROGRESS, 'game_contract: INVALID_STATUS');
        
        let winner = match _validate_game(game_state, turns) {
            GameResult::Winner1(()) => {
                game.player_1
            },
            GameResult::Winner2(()) => {
                game.player_2
            },
            GameResult::Cheater1(()) => {
                game.player_2
            },
            GameResult::Cheater2(()) => {
                game.player_1
            },
        };

        _games::write(
            game_id,
            Game {
                status: Constants::FINISHED,
                winner,
                player_1: game.player_1,
                player_2: game.player_2,
                mechas_player_1: game.mechas_player_1,
                mechas_player_2: game.mechas_player_2,
            }
        );
    }

    #[view]
    fn get_game(game_id: u128) -> Game {
        _games::read(game_id)
    }

    #[external]
    fn upgrade(new_class_hash: ClassHash) {
        assert_only_owner();
        replace_class_syscall(new_class_hash);
    }

    fn assert_only_owner() {
        let owner: ContractAddress = _owner::read();
        let caller: ContractAddress = get_caller_address();
        assert(caller == owner, 'game_contract: ONLY_OWNER');
    }

    #[view]
    fn nothing(position: Position, action: Action, game_state: GameState, mecha_state: MechaState) -> u128 {
        0
    }
}
