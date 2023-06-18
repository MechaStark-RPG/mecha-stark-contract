use mecha_stark::game::entities::{Action, Game, Position};

#[abi]
trait IMechaStarkContract {
    fn create_game();
    fn validate_game(actions: Array<Action>);
    fn get_game(id_game: u128) -> u32;
}

#[contract]
mod MechaStarkContract {
    
    use traits::Into;
    use array::ArrayTrait;
    use starknet::ContractAddress;

    use super::{Action, Game, Position};
    use super::IMechaStarkContract;
    // use mecha_stark::game::storage::{GameStorageAccess};
    // use mecha_stark::serde::{SpanSerde};

    struct Storage {
        counter: u128
        // game: LegacyMap::<u128, Game>,
    }

    #[constructor]
    fn init(initial_counter: u128) {
        counter::write(initial_counter);
    }

    // impl MechaStarkContractImpl of IMechaStarkContract {
        
    #[external]
    fn create_game() {
        // falta implementar el storage
    }
    
    #[external]
    // crear un array de actions con el botardo
    fn validate_game(actions: Array<Action>) {
        // TEMPORAL: crear un metodo que cree el state del juego(los mechas se cargan)
        // hacer validadciones de cada jugada y actualizar el state del juego
        // ver quien gano

        let mut action_0 = *actions.at(0);
        // self.counter.read()
        // action_0.id_mecha
        // action_0.attack.x
    }

    #[view]
    fn get_game(id_game: u128) -> u32 {
        100
    }
    // }
}
