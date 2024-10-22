
# Bridge Contract
## Overview
The Bridge contract facilitates ERC20 cross-chain transfers by handling deposits and withdrawals between supported chains. It ensures secure and validated token transfers using Merkle proofs and cryptographic signatures.

## Functions
### `deposit`
#### Purpose: Allows users to deposit ERC20 tokens to the target chain.

#### Parameters:

- ChainId target: The target chain ID where the tokens will be transferred.
- Token token: The token to be deposited.
- uint256 amount: The amount of tokens to be deposited.

#### Details:
- Creates a bridge message containing transaction details.
- Transfers the specified tokens from the sender to the contract.
- Emits a Deposit event with the encoded bridge message.

### `withdraw`
#### Purpose: Allows users to withdraw ERC20 tokens from the source chain.

#### Parameters:

- BridgeMessage calldata bridgeMsg: The bridge message containing the details of the transaction.
- bytes32[] calldata proof: The Merkle proof validating the transaction.

#### Details:

- Validates the bridge message and Merkle proof.
- Determines the output token (wrapped or original).
- Transfers the specified tokens from the contract to the recipient.
- Emits a Withdraw event with the transaction details.

### `update`
#### Purpose: Updates the Merkle root of the source chain.

#### Parameters:

- UpdateHashMessage calldata updateMsg: The update message containing the new Merkle roots and block numbers.
- bytes[] calldata signatures: The cryptographic signatures validating the update.

#### Details:

- Validates the update message and signatures.
- Sets the new Merkle root for each specified block number.
- Emits an Update event with the update details.

### `updateQuorum`
#### Purpose: Updates the quorum of the target chain.

#### Parameters:

- UpdateQuorumMessage calldata updateMsg: The update message containing the new signers.
- bytes[] calldata signatures: The cryptographic signatures validating the update.

### Details:

- Validates the update message and signatures.
- Sets the new quorum of signers.
- Emits an UpdateQuorum event with the update details.

### `setMinimumConfirmation`
#### Purpose: Sets the minimum confirmation for a specific chain.

#### Parameters:

- SetChainConfigMessage calldata setMsg: The chain config message containing the new minimum confirmation.
- bytes[] calldata signatures: The cryptographic signatures validating the update.

#### Details:

- Validates the set message and signatures.
- Sets the new minimum confirmation for the specified chain.
- Emits a SetChainConfig event with the update details.

## Installation:

1. Clone
```
$ git clone https://github.com/havi-kim/simple_bridge
$ cd simple_bridge
```
2. Install foundry
```azure
$ curl -L https://foundry.paradigm.xyz | bash
$ foundryup
```
3. Compile
```azure
$ forge build
```
4. Test
```azure
$ forge test
```
5. Run script
```
$ PK=0x... forge script scripts/....sol --rpc-url http://... --broadcast

```
