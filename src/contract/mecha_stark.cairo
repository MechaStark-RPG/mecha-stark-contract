#[contract]
mod MechaStark {
    use starknet::ContractAddress;
    use mecha_stark::business_logic::storage::GameStorageAccess;
    use mecha_stark::business_logic::serde::SpanSerde;

    struct Storage {
        game: LegacyMap::<u128, Game>,
    }

    #[derive(Drop, Serde)]
    struct Game {
        turn_id: u128,
        current_player_turn: ContractAddress,
        winner: ContractAddress,
        map_id: u128,
        mechas_ids: Span<u128>,
        players: Span<ContractAddress>,
    }

    #[external]
    fn create_game(data: Array<u256>) {
    }

    #[external]
    fn validate_game(data: Array<u256>) {
    }

    // Returns the current balance.
    #[view]
    fn get_game(game_id: u128) -> Game {
        game::read(game_id)
    }
}
