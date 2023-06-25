use mecha_stark::components::turn::{Turn};
use mecha_stark::components::game::{Game};
use mecha_stark::components::game_state::{GameState};
use starknet::{ContractAddress, ClassHash};

#[abi]
trait IERC20 {
    fn name() -> felt252;
    fn symbol() -> felt252;
    fn decimals() -> u8;
    fn totalSupply() -> u256;
    fn balanceOf(account: ContractAddress) -> u256;
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(recipient: ContractAddress, amount: u256);
    fn transferFrom(sender: ContractAddress, recipient: ContractAddress, amount: u256);
    fn approve(spender: ContractAddress, amount: u256);
    fn increaseAllowance(spender: ContractAddress, added_value: u256);
    fn decreaseAllowance(spender: ContractAddress, subtracted_value: u256);
    fn mint(recipient: ContractAddress, amount: u256);
}

#[abi]
trait IMechaStarkContract {
    #[external]
    fn create_game(mechas_id: Array<felt252>, bet: u256);
    #[external]
    fn join_game(id_game: u128, mechas_id: Array<felt252>);
    #[view]
    fn validate_game(game_state: GameState, turns: Array<Turn>) -> bool;
    #[external]
    fn finish_game(id_game: u128, game_state: GameState, turns: Array<Turn>);
    #[view]
    fn get_game(id_game: u128) -> Game;
    #[external]
    fn claimRewards(user: ContractAddress);
    #[external]
    fn upgrade(new_class_hash: ClassHash);
}

#[contract]
mod MechaStarkContract {
    use array::{ArrayTrait, SpanTrait};
    use starknet::{
        ContractAddress, ClassHash, get_caller_address, get_contract_address, replace_class_syscall
    };
    use traits::{Into, TryInto};

    use mecha_stark::components::turn::{Action, ActionTrait, TypeAction, Turn};
    use mecha_stark::components::game::{Game, GameStatus, MechaAttributes};
    use mecha_stark::components::game_state::{GameState, MechaState};
    use mecha_stark::components::game_state_manager::_validate_game;
    use mecha_stark::components::position::{Position, PositionTrait};
    use mecha_stark::components::mecha_data_helper::{
        MechaDict, MechaDictTrait, MechaStaticData, MechaStaticDataTrait
    };
    use mecha_stark::utils::storage::{GameStorageAccess};
    use mecha_stark::utils::serde::{SpanSerde};

    use super::{IERC20Dispatcher, IERC20DispatcherTrait};

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
    fn create_game(mechas_id: Array<felt252>, bet: u256) {
        assert(mechas_id.len() == 5, 'Se deben enviar 5 mechas');

        // apuesta
        // si ya tengo balance que me deje jugar directo
        // let balance = _balances::read(user);
        // if balance < bet {
        //     let contract = get_contract_address();
        //     let token = IERC20Dispatcher { contract_address: _token::read() };
        //     let approved: u256 = token.allowance(user, contract);
        //     assert(approved > bet, 'Not approved');
        //     token.transferFrom(user, contract, bet);
        // } else {
        //     _balances::write(user, balance - bet);
        // }
        // emitir evento
        //

        // validar que los mechas sean del mismo owner
        let player_address = get_caller_address();
        _games::write(
            _count_games::read(),
            Game {
                bet: 1,
                size: 2,
                status: 0,
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
    fn claimRewards(user: ContractAddress) {
        let contract = get_contract_address();
        let balance = _balances::read(user);
        assert(balance > 0, 'Dont have balance');
        let usd_token = IERC20Dispatcher { contract_address: _token::read() };
        _balances::write(user, 0);
        usd_token.mint(user, balance);
    }

    #[external]
    fn join_game(id_game: u128, mechas_id: Array<felt252>) {
        assert(mechas_id.len() == 5, 'Se deben enviar 5 mechas');

        // Validar que los mechas sean del mismo owner
        let game = _games::read(id_game);
        // assert(game.status == StatusGame::Waiting(()), 'join_game - game is not waiting');

        // apuesta
        // si ya tengo balance que me deje jugar directo
        // let balance = _balances::read(user);
        // let bet = 1_u256; // ver por que no se guardar en u256
        // if balance < bet {
        //     let contract = get_contract_address();
        //     let usd_token = IERC20Dispatcher { contract_address: _token::read() };
        //     let approved: u256 = usd_token.allowance(user, contract);
        //     assert(approved > bet, 'Not approved');
        //     usd_token.transferFrom(user, contract, bet);
        // } else {
        //     _balances::write(user, balance - bet);
        // }
        // emitir evento
        //

        let player_address = get_caller_address();
        _games::write(
            id_game,
            Game {
                bet: game.bet, // ver por que no se guardar en u256
                size: game.size,
                status: 1,
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
            GameStatus::Winner1(()) => true,
            GameStatus::Winner2(()) => true,
            GameStatus::Cheater1(()) => false,
            GameStatus::Cheater2(()) => false,
        }
    }

    #[external]
    fn finish_game(id_game: u128, game_state: GameState, turns: Array<Turn>) {// machear el id game con el game state

    // match _validate_game(game_state, turns) {
    //     GameStatus::Winner1(()) => {

    //     },
    //     GameStatus::Winner2(()) => {

    //     },
    //     GameStatus::Cheater1(()) => {

    //     },
    //     GameStatus::Cheater2(()) => {

    //     },
    // };
    }

    #[view]
    fn get_game(id_game: u128) -> Game {
        _games::read(id_game)
    }

    #[external]
    fn upgrade(new_class_hash: ClassHash) {
        assert_only_owner();
        replace_class_syscall(new_class_hash);
    }

    fn assert_only_owner() {
        let owner: ContractAddress = _owner::read();
        let caller: ContractAddress = get_caller_address();
        assert(caller == owner, 'Only owner');
    }
}
