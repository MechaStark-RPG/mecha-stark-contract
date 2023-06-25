use array::{ArrayTrait, SpanTrait};
use traits::{Into, TryInto};
use option::OptionTrait;
use starknet::{
    ContractAddress, StorageAccess, storage_address_from_base_and_offset,
    storage_base_address_from_felt252, Felt252TryIntoContractAddress, ContractAddressIntoFelt252,
    storage_read_syscall, storage_write_syscall, SyscallResult, StorageBaseAddress,
};

use integer::{Felt252TryIntoU128, U128IntoFelt252};

use mecha_stark::components::game::{Game};
use mecha_stark::utils::serde::{SpanSerde};

impl ContractAddressSpanStorageAccess of StorageAccess<Span<ContractAddress>> {
    fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult<Span<ContractAddress>> {
        let mut arr: Array<ContractAddress> = ArrayTrait::new();

        // Read span len
        let len: u8 = storage_read_syscall(
            :address_domain, address: storage_address_from_base_and_offset(base, 0_u8)
        )?
            .try_into()
            .expect('Storage - Span too large');

        // Load span content
        let mut i: u8 = 1;
        loop {
            if (i > len) {
                break ();
            }

            match storage_read_syscall(
                :address_domain, address: storage_address_from_base_and_offset(base, i)
            ) {
                Result::Ok(element) => {
                    let contract_address = StorageAccess::<felt252>::read(address_domain, base)?
                        .try_into()
                        .expect('Non ContractAddress');
                    arr.append(contract_address)
                },
                Result::Err(_) => panic_with_felt252('Storage - Unknown error'),
            }

            i += 1;
        };

        Result::Ok(arr.span())
    }

    fn write(
        address_domain: u32, base: StorageBaseAddress, mut value: Span<ContractAddress>
    ) -> SyscallResult<()> {
        // Assert span can fit in storage obj
        // 1 slots for the len; 255 slots for the span content
        let len: u8 = Into::<u32, felt252>::into(value.len())
            .try_into()
            .expect('Storage - Array too large');

        // Write span content
        let mut i: u8 = 1;
        loop {
            match value.pop_front() {
                Option::Some(element) => {
                    let contract_felt: felt252 =
                        starknet::contract_address::contract_address_to_felt252(
                        *element
                    );

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

impl Felt252SpanStorageAccess of StorageAccess<Span<felt252>> {
    fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult<Span<felt252>> {
        let mut arr = ArrayTrait::new();

        // Read span len
        let len: u8 = storage_read_syscall(
            :address_domain, address: storage_address_from_base_and_offset(base, 0_u8)
        )?
            .try_into()
            .expect('Storage - Span too large');

        // Load span content
        let mut i: u8 = 1;
        loop {
            if (i > len) {
                break ();
            }

            match storage_read_syscall(
                :address_domain, address: storage_address_from_base_and_offset(base, i)
            ) {
                Result::Ok(element) => {
                    arr.append(element)
                },
                Result::Err(_) => panic_with_felt252('Storage - Unknown error'),
            }

            i += 1;
        };

        Result::Ok(arr.span())
    }

    fn write(
        address_domain: u32, base: StorageBaseAddress, mut value: Span<felt252>
    ) -> SyscallResult<()> {
        // Assert span can fit in storage obj
        // 1 slots for the len; 255 slots for the span content
        let len: u8 = Into::<u32, felt252>::into(value.len())
            .try_into()
            .expect('Storage - Span too large');

        // Write span content
        let mut i: u8 = 1;
        loop {
            match value.pop_front() {
                Option::Some(element) => {
                    storage_write_syscall(
                        :address_domain,
                        address: storage_address_from_base_and_offset(base, i),
                        value: *element
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
        let size_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 0_u8).into()
        );
        let size = StorageAccess::read(address_domain, size_base)?;

        let bet_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 1_u8).into()
        );
        let bet = StorageAccess::read(address_domain, bet_base)?;

        let status_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 2_u8).into()
        );
        let status = StorageAccess::read(address_domain, status_base)?;

        let winner_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 3_u8).into()
        );
        let winner = StorageAccess::read(address_domain, winner_base)?;

        let player_1_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 4_u8).into()
        );
        let player_1 = StorageAccess::read(address_domain, player_1_base)?;

        let player_2_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 5_u8).into()
        );
        let player_2 = StorageAccess::read(address_domain, player_2_base)?;

        let mechas_player_1_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 6_u8).into()
        );
        let mechas_player_1 = StorageAccess::read(address_domain, mechas_player_1_base)?;

        let mechas_player_2_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 12_u8).into()
        );
        let mechas_player_2 = StorageAccess::read(address_domain, mechas_player_2_base)?;

        Result::Ok(Game { size, bet, status, winner, player_1, player_2, mechas_player_1, mechas_player_2 })
    }

    fn write(address_domain: u32, base: StorageBaseAddress, mut value: Game) -> SyscallResult<()> {
        let size_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 0_u8).into()
        );
        StorageAccess::write(address_domain, size_base, value.size)?;

        let bet_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 1_u8).into()
        );
        StorageAccess::write(address_domain, bet_base, value.bet)?;

        let status_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 2_u8).into()
        );
        StorageAccess::write(address_domain, status_base, value.status)?;

        let winner_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 3_u8).into()
        );
        StorageAccess::write(address_domain, winner_base, value.winner)?;

        let player_1_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 4_u8).into()
        );
        StorageAccess::write(address_domain, player_1_base, value.player_1)?;

        let player_2_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 5_u8).into()
        );
        StorageAccess::write(address_domain, player_2_base, value.player_2)?;

        let mechas_player_1_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 6_u8).into()
        );
        StorageAccess::write(address_domain, mechas_player_1_base, value.mechas_player_1)?;

        let mechas_player_2_base = storage_base_address_from_felt252(
            storage_address_from_base_and_offset(base, 12_u8).into()
        );
        StorageAccess::write(address_domain, mechas_player_2_base, value.mechas_player_2)?;

        SyscallResult::Ok(())
    }
}
