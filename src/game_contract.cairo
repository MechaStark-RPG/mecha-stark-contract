use mecha_stark::components::turn::{Turn};
use mecha_stark::components::game::{Game};
use mecha_stark::components::game_state::{GameState};
use starknet::ContractAddress;

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
    fn create_game(mechas_id: Array<felt252>, bet: u256, user: ContractAddress);
    #[external]
    fn join_game(id_game: u128, mechas_id: Array<felt252>, user: ContractAddress);
    #[view]
    fn validate_game(game_state: GameState, turns: Array<Turn>) -> bool;
    #[external]
    fn finish_game(id_game: u128, game_state: GameState, turns: Array<Turn>);
    #[view]
    fn get_game(id_game: u128) -> Game;
    #[external]
    fn claimRewards(user: ContractAddress);
}

#[contract]
mod MechaStarkContract {
    use array::{ArrayTrait, SpanTrait};
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use traits::{ Into, TryInto };

    use mecha_stark::components::turn::{Action, ActionTrait, TypeAction, Turn};
    use mecha_stark::components::game::{Game, StatusGame, MechaAttributes};
    use mecha_stark::components::game_state::{GameState, PlayerState, MechaState};
    use mecha_stark::components::game_state_manager::_validate_game;
    use mecha_stark::components::position::{Position, PositionTrait};
    use mecha_stark::components::mecha_data_helper::{
        MechaDict, MechaDictTrait, MechaStaticData, MechaStaticDataTrait
    };
    use mecha_stark::utils::storage::{GameStorageAccess};
    use mecha_stark::utils::serde::{SpanSerde};

    use super::{ IERC20Dispatcher, IERC20DispatcherTrait };

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
    fn create_game(mechas_id: Array<felt252>, bet: u256, user: ContractAddress) {
        assert(mechas_id.len() == 5, 'Se deben enviar 5 mechas');

        // apuesta
        // si ya tengo balance que me deje jugar directo
        let balance = _balances::read(user);
        if balance < bet {
            let contract = get_contract_address();
            let usd_token = IERC20Dispatcher { contract_address: _token::read() };
            let approved: u256 = usd_token.allowance(user, contract);
            assert(approved > bet, 'Not approved');
            usd_token.transferFrom(user, contract, bet);
        } else {
            _balances::write(user, balance - bet);
        }
        // emitir evento
        //

        // Validar que los mechas sean del mismo owner
        let player_address = get_caller_address();
        _games::write(_count_games::read(), Game {
            bet: 1,
            size: 2,
            status: StatusGame::Waiting(()),
            winner: starknet::contract_address_const::<0>(),
            player_1: player_address,
            player_2: starknet::contract_address_const::<0>(),
            mechas_player_1: mechas_id.span(),
            mechas_player_2: ArrayTrait::new().span(),
        });

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
    fn join_game(id_game: u128, mechas_id: Array<felt252>, user: ContractAddress) {

        assert(mechas_id.len() == 5, 'Se deben enviar 5 mechas');
        // Validar que los mechas sean del mismo owner
        let game = _games::read(id_game);
        // assert(game.status == StatusGame::Waiting(()), 'join_game - game is not waiting');

        // apuesta
        // si ya tengo balance que me deje jugar directo
        let balance = _balances::read(user);
        let bet = 1_u256; // ver por que no se guardar en u256
        if balance < bet {
            let contract = get_contract_address();
            let usd_token = IERC20Dispatcher { contract_address: _token::read() };
            let approved: u256 = usd_token.allowance(user, contract);
            assert(approved > bet, 'Not approved');
            usd_token.transferFrom(user, contract, bet);
        } else {
            usd_token.transferFrom(user, contract, bet);
            _balances::write(user, balance - bet);
        }
        // emitir evento
        //

        let player_address = get_caller_address();
        _games::write(id_game, Game {
            bet: game.bet, // ver por que no se guardar en u256
            size: game.size,
            status: StatusGame::Progress(()),
            winner: game.winner,
            player_1: game.player_1,
            player_2: player_address,
            mechas_player_1: game.mechas_player_1,
            mechas_player_2: mechas_id.span(),
        });
    }

    #[view]
    fn validate_game(game_state: GameState, turns: Array<Turn>) -> bool {
        _validate_game(game_state, turns)
    }

    #[external]
    fn finish_game(id_game: u128, game_state: GameState, turns: Array<Turn>) {
        assert_only_owner();
        if _validate_game(game_state, turns) {
            // let bet = get_bet_by_game()
            // _balances::write(user_winner, balance + bet);
        } else {
            panic_with_felt252('Mecha stark - finishing game');
        }
    }

    #[view]
    fn get_game(id_game: u128) -> Game {
        _games::read(id_game)
    }

    fn assert_only_owner() {
        let owner: ContractAddress = _owner::read();
        let caller: ContractAddress = get_caller_address();
        assert(caller == owner, 'Only owner');
    }
}
