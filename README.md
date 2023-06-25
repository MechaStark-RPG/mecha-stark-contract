![mechabg](https://github.com/MechaStark-RPG/mecha-stark-contract/assets/30808181/3265a6fa-7501-4042-bf65-bcadc9ce214d)

# MechaStark RPG
MechaStark-RPG is a 2D multiplayer turn-based strategy game where you can battle with your mechas (NFTs) and place bets on matches, with the validation of the game being processed and supported by Starknet.

## Architecture
![image](https://github.com/MechaStark-RPG/mecha-stark-contract/assets/30808181/bf6c49de-1b99-44e8-871b-9115570bc0bd)

## Demo

- MechaStarkRPG: locally only
- Presentation [here](https://www.canva.com/design/DAFm0IvsAPw/W3lNMpcbdJ3lKz3ps1wtdA/edit?utm_content=DAFm0IvsAPw&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

## Contract

- Cairo Version: 1.1.0
- Contract deployed(goerli): **0x00F937c28d624F4CdC96FdA0B609c41F62DB99B0dB9501dD0d000a4A40057225**

### Usage

#### Scarb 
```bash
scarb build       # Build contract
scarb test        # Run the test in src/tests
scarb fmt         # Format
```
[Documentation](https://docs.swmansion.com/scarb) 

#### Starkli

declare contract
```bash
starkli declare --watch --keystore ~/starkli-accounts/account1_key --account ~/starkli-accounts/account1_account ./target/dev/mecha_stark_MechaStarkContract.sierra.json
```

deploy contract
```bash
starkli deploy --watch --keystore ~/starkli-accounts/account1__key --account ~/starkli-accounts/account1_account <CLASSHASH> <TOKEN>
```
[Documentation](https://github.com/xJonathanLEI/starkli)

## Frontend
Repository: https://github.com/MechaStark-RPG/mecha-stark-frontend

## Backend
Repository: https://github.com/MechaStark-RPG/mecha-stark-backend

## Next step

- Complexify game mechanics for richer gameplay:
  - Miss attacks, land effects, different weapons with ranges and damage.
- Introduce RNG factor:
  -Incorporate seeds for random number generation.
- Upgrade networking capabilities:
  - Replace Socket I/O backend with WebRTC or P2P technology.
Implement ERC-1155 contract with NFTs:
  -Mine daily mecha pieces (e.g., head, chest, legs, arms, weapons) with unique attributes for customization.
- Establish game economy:
  -Include stakes, tokens, and NFT trades for economic interaction.


