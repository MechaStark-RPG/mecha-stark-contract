use array::{ ArrayTrait, SpanTrait };
use traits::{ Into, TryInto };
use option::OptionTrait;
use starknet::{
  ContractAddress,
  StorageAccess,
  storage_address_from_base_and_offset,
  storage_base_address_from_felt252,
  Felt252TryIntoContractAddress,
  ContractAddressIntoFelt252,
  storage_read_syscall,
  storage_write_syscall,
  SyscallResult,
  StorageBaseAddress,
};

use integer::{
  Felt252TryIntoU128,
  U128IntoFelt252
};

use mecha_stark::contract::mecha_stark::MechaStark::Game;

fn returns_two() -> felt252 {
    2
}

impl ContractAddressSpanStorageAccess of StorageAccess<Span<ContractAddress>> {
  fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult<Span<ContractAddress>> {
    let mut arr: Array<ContractAddress> = ArrayTrait::new();

    // Read span len
    let len: u8 = storage_read_syscall(:address_domain, address: storage_address_from_base_and_offset(base, 0_u8))?
      .try_into()
      .expect('Storage - Span too large');

    // Load span content
    let mut i: u8 = 1;
    loop {
      if (i > len) {
        break ();
      }

      match storage_read_syscall(:address_domain, address: storage_address_from_base_and_offset(base, i)) {
        Result::Ok(element) => {
          let contract_address = StorageAccess::<felt252>::read(address_domain, base)?.try_into().expect('Non ContractAddress');
          arr.append(contract_address)
        },
        Result::Err(_) => panic_with_felt252('Storage - Unknown error'),
      }

      i += 1;
    };

    Result::Ok(arr.span())
  }

  fn write(address_domain: u32, base: StorageBaseAddress, mut value: Span<ContractAddress>) -> SyscallResult<()> {
    // Assert span can fit in storage obj
    // 1 slots for the len; 255 slots for the span content
    let len: u8 = Into::<u32, felt252>::into(value.len()).try_into().expect('Storage - Array too large');

    // Write span content
    let mut i: u8 = 1;
    loop {
      match value.pop_front() {
        Option::Some(element) => {
          let contract_felt: felt252 = starknet::contract_address::contract_address_to_felt252(*element);
          
          storage_write_syscall(
            :address_domain,
            address: storage_address_from_base_and_offset(base, i),
            value: contract_felt
          );
          i += 1;
        },
        Option::None(_) => {
          break ();
        },
      };
    };

    // Store span len
    StorageAccess::<felt252>::write(:address_domain, :base, value: len.into())
  }
}


impl U128SpanStorageAccess of StorageAccess<Span<u128>> {
  fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult<Span<u128>> {
    let mut arr: Array<u128> = ArrayTrait::new();

    // Read span len
    let len: u8 = storage_read_syscall(:address_domain, address: storage_address_from_base_and_offset(base, 0_u8))?
      .try_into()
      .expect('Storage - Span too large');

    // Load span content
    let mut i: u8 = 1;
    loop {
      if (i > len) {
        break ();
      }

      match storage_read_syscall(:address_domain, address: storage_address_from_base_and_offset(base, i)) {
        Result::Ok(element) => {
          arr.append(element.try_into().unwrap())
        },
        Result::Err(_) => panic_with_felt252('Storage - Unknown error'),
      }

      i += 1;
    };

    Result::Ok(arr.span())
  }

  fn write(address_domain: u32, base: StorageBaseAddress, mut value: Span<u128>) -> SyscallResult<()> {
    // Assert span can fit in storage obj
    // 1 slots for the len; 255 slots for the span content
    let len: u8 = Into::<u32, felt252>::into(value.len()).try_into().expect('Storage - Array too large');

    // Write span content
    let mut i: u8 = 1;
    loop {
      match value.pop_front() {
        Option::Some(element) => {
          let elem = *element; 
          storage_write_syscall(
            :address_domain,
            address: storage_address_from_base_and_offset(base, i),
            value: elem.into()
          );
          i += 1;
        },
        Option::None(_) => {
          break ();
        },
      };
    };

    // Store span len
    StorageAccess::<felt252>::write(:address_domain, :base, value: len.into())
  }
}

impl GameStorageAccess of StorageAccess<Game> {
  fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult<Game> {
    let turn_id_base = storage_base_address_from_felt252(storage_address_from_base_and_offset(base, 0_u8).into());
    let turn_id = StorageAccess::read(address_domain, turn_id_base)?;

    let current_player_turn_base = storage_base_address_from_felt252(storage_address_from_base_and_offset(base, 1_u8).into());
    let current_player_turn = StorageAccess::read(address_domain, current_player_turn_base)?;

    let winner_base = storage_base_address_from_felt252(storage_address_from_base_and_offset(base, 2_u8).into());
    let winner = StorageAccess::read(address_domain, winner_base)?;

    let map_id_base = storage_base_address_from_felt252(storage_address_from_base_and_offset(base, 3_u8).into());
    let map_id = StorageAccess::read(address_domain, map_id_base)?;

    let mechas_ids_base = storage_base_address_from_felt252(storage_address_from_base_and_offset(base, 4_u8).into());
    let mechas_ids = StorageAccess::read(address_domain, mechas_ids_base)?;

    let players_base = storage_base_address_from_felt252(storage_address_from_base_and_offset(base, 4_u8).into());
    let players = StorageAccess::read(address_domain, map_id_base)?;

    Result::Ok( Game { turn_id, current_player_turn, winner, map_id, mechas_ids, players  })
  }

  fn write(address_domain: u32, base: StorageBaseAddress, mut value: Game) -> SyscallResult<()> {
    let turn_id_base = storage_base_address_from_felt252(storage_address_from_base_and_offset(base, 0_u8).into());
    StorageAccess::write(address_domain, turn_id_base, value.turn_id)
  }
}