use mecha_stark::contract::mecha_stark::MechaStark::Game;
use mecha_stark::business_logic::core::Action;
use option::OptionTrait;

impl U256TryIntoAction of TryInto<u256, Action> {
    fn try_into(self: u256) -> Option<Action> {
        DataToStructAction::map(self)
    }
}

trait DataToStruct<T> {
    fn map(data: u256) -> T;
} 

impl DataToStructAction of DataToStruct<Option<Action>> {
    fn map(data: u256) -> Option<Action> {
        Option::None(())
    }

}
