# Dilithium Solidity

Dilithium Solidity is a Solidity implementation of the [Dilithium signature scheme](https://pq-crystals.org/dilithium/), a post-quantum digital signature algorithm. This library provides a secure and efficient way to generate and verify Dilithium signatures within Ethereum smart contracts.

## `Dilithium.sol` Benchmark

| Deployment Cost | Deployment Size (Bytes) |
| --------------- | ----------------------- |
| 3465236         | 15969                   |

| Function Name       | Gas Cost |
| ------------------- | -------- |
| expand              | 10006057 |
| unpackPk            | 702994   |
| unpackSig           | 1579346  |
| verifyExpanded      | 11293070 |
| verifyExpandedBytes | 12566454 |
