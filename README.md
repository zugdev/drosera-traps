## AutoLotterTrap.sol

A trap for a lottery where each round last 10mins or bet volume reaches certain amount.

This trap detects when a round is over and automates ending a round, which means paying out and starting the next one.

## [holesky]

MockUSD: [0xf0c14ce46ba2657a2982942f121f1484f2f03aec](https://holesky.etherscan.io/address/0xf0c14ce46ba2657a2982942f121f1484f2f03aec)

Lottery: [0xc83ffb298acac98195b485e4c566eab99814ab57](https://holesky.etherscan.io/address/0xc83ffb298acac98195b485e4c566eab99814ab57)

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
