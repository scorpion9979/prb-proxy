# PRBProxy [![Github Actions][gha-badge]][gha] [![Coverage][codecov-badge]][codecov] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gha]: https://github.com/PaulRBerg/prb-proxy/actions
[gha-badge]: https://github.com/PaulRBerg/prb-proxy/actions/workflows/ci.yml/badge.svg
[codecov]: https://codecov.io/gh/PaulRBerg/prb-proxy
[codecov-badge]: https://codecov.io/gh/PaulRBerg/prb-proxy/branch/main/graph/badge.svg?token=4YV6JCTO9R
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

PRBProxy is a **proxy contract that allows for the composition of Ethereum transactions on behalf of the contract owner**, acting as a smart wallet
that enables multiple contract calls within a single transaction. In Ethereum, externally owned accounts (EOAs) do not have this functionality; they
are limited to interacting with only one contract per transaction.

Some key features of PRBProxy include:

- Forwarding calls with [`DELEGATECALL`][se-3667]
- Use of [CREATE2][eip-1014] to deploy the proxies at deterministic addresses.
- A unique registry system ensures that each user has a distinct proxy.
- An access control system that permits third-party accounts (called "envoys") to call target contracts on behalf of the owner.
- A plugin system that enables the proxy to respond to callbacks.
- Reversion with custom errors rather than reason strings for improved error handling.
- Comprehensive documentation via NatSpec comments.
- Development and testing using Foundry.

Overall, PRBProxy is a powerful tool for transaction composition, providing numerous features and benefits not available through EOAs.

## Install

### Foundry

First, run the install step:

```sh
forge install PaulRBerg/prb-proxy@release-v4
```

Your `.gitmodules` file should now contain the following entry:

```toml
[submodule "lib/prb-proxy"]
  branch = "release-v4"
  path = "lib/prb-proxy"
  url = "https://github.com/PaulRBerg/prb-proxy"
```

Finally, add this to your `remappings.txt` file:

```text
prb-proxy/=lib/prb-proxy/src/
```

### Hardhat

PRBProxy is available as an npm package:

```sh
pnpm add @prb/proxy
```

## Background

The concept of a forwarding proxy has gained popularity thanks to DappHub, the developer team behind the decentralized stablecoin
[DAI](https://makerdao.com). DappHub created [DSProxy](https://github.com/dapphub/ds-proxy), a widely used tool that allows for the execution of
multiple contract calls in a single transaction. Major DeFi players like Maker, Balancer, and DeFi Saver all rely on DSProxy.

However, as the Ethereum ecosystem has evolved since DSProxy's launch in 2017, the tool has become outdated. With significant improvements to the
Solidity compiler and new EVM OPCODES, as well as the introduction of more user-friendly development environments like
[Foundry](https://book.getfoundry.sh/), it was time for an update.

Enter PRBProxy, the modern successor to DSProxy; a "DSProxy 2.0", if you will. It improves upon DSProxy in several ways:

1. PRBProxy is deployed with [CREATE2][eip-1014], which allows clients to pre-compute the proxy contract's address.
2. The `CREATE2` salts are generated in a way that eliminates the risk of front-running.
3. The proxy owner is immutable, and so it cannot be changed during any `DELEGATECALL`.
4. PRBProxy uses high-level Solidity code that is easier to comprehend and less prone to errors.
5. PRBProxy offers more features than DSProxy.

Using CREATE2 eliminates the risk of a [chain reorg](https://en.bitcoin.it/wiki/Chain_Reorganization) overriding the proxy contract owner, making
PRBProxy a more secure alternative to DSProxy. With DSProxy, users must wait for several blocks to be mined before assuming the contract is secure.
However, PRBProxy eliminates this risk entirely, making it possible to safely send funds to the proxy before it is deployed.

## Usage

There are multiple ways to deploy a proxy:

| Function                     | Description                                                                                              |
| ---------------------------- | -------------------------------------------------------------------------------------------------------- |
| `deploy`                     | Deploy a proxy for `msg.sender`                                                                          |
| `deployFor`                  | Deploy a proxy for the provided `owner`                                                                  |
| `deployAndExecute`           | Deploy a proxy for `msg.sender`, and delegate calls to the provided target                               |
| `deployAndInstallPlugin`     | Deploy a proxy for `msg.sender`, and installs the provided plugin                                        |
| `deployAndExecuteAndInstall` | Deploy a proxy for `msg.sender`, delegate calls to the provided target, and installs the provided plugin |

Once the proxy is deployed, you can start interacting with target contracts by calling the `execute` function on the proxy by passing the ABI-encoding
function signatures and data.

### Documentation

See this repository's [wiki](https://github.com/PaulRBerg/prb-proxy/wiki) page for guidance on how to write plugins, targets, and front-end
integrations.

### Addresses

The registry is deployed on the following chain:

| Contract         | Chain          | [Chain ID](https://chainlist.org/) | Address                                                                                                                           |
| ---------------- | -------------- | ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| PRBProxyRegistry | Goerli Testnet | 5                                  | [0x33e200B5fb5e0C57d370d5202c26A35d07A46B98](https://goerli.etherscan.io/address/0x33e200B5fb5e0C57d370d5202c26A35d07A46B98#code) |

### Frontends

Integrating PRBProxy into a frontend app would look something like this:

1. Begin by calling the `getProxy` function on the registry to determine if the user already has a proxy.
2. If the user does not have a proxy, deploy one for them using one of the deploy methods outlined above.
3. Interact with your desired target contract using the `execute` function.
4. Install relevant plugins, which can make the proxy react to your protocol events.
5. Going forward, treat the proxy address as the user of your system.

However, this is just scratching the surface. For more examples of how to use PRBProxy in a frontend environment, check out the [Frontends][frontends]
wiki. Additionally, Maker's developer guide, [Working with DSProxy][dsproxy-guide], provides an in-depth exploration of the proxy concept that can
also help you understand how to use PRBProxy. Just be sure to keep in mind the differences outlined throughout this document.

## Gas Efficiency

It costs ~528,529 gas to deploy a PRBProxy, whereas a DSProxy costs 596,198 gas - a reduction in deployment costs of roughly 12%.

The `execute` function in PRBProxy is slightly more expensive than in its counterpart, due to the safety checks in our implementation. However, the
majority of gas cost when calling `execute` is due to the target contract.

## Contributing

Feel free to dive in! [Open](https://github.com/PaulRBerg/prb-proxy/issues/new) an issue,
[start](https://github.com/PaulRBerg/prb-proxy/discussions/new) a discussion, or submit a PR.

### Pre Requisites

You will need the following software on your machine:

- [Git](https://git-scm.com/downloads)
- [Foundry](https://github.com/foundry-rs/foundry)
- [Node.Js](https://nodejs.org/en/download/)
- [Pnpm](https://pnpm.io)

In addition, familiarity with [Solidity](https://soliditylang.org/) is requisite.

### Set Up

Clone this repository including submodules:

```sh
$ git clone --recurse-submodules -j8 git@github.com:PaulRBerg/prb-proxy.git
```

Then, inside the project's directory, run this to install the Node.js dependencies:

```sh
$ pnpm install
```

Now you can start making changes.

### Syntax Highlighting

You will need the following VSCode extensions:

- [hardhat-solidity](https://marketplace.visualstudio.com/items?itemName=NomicFoundation.hardhat-solidity)
- [vscode-tree-language](https://marketplace.visualstudio.com/items?itemName=CTC.vscode-tree-extension)

## Security

While I have strict standards for code quality and test coverage, it's important to note that this project may not be entirely risk-free. Although I
have taken measures to ensure the security of PRBProxy, it has not yet been audited by a third-party security researcher.

### Caveat Emptor

Please be aware that this software is experimental and is provided on an "as is" and "as available" basis. I do not offer any warranties, and I cannot
be held responsible for any direct or indirect loss resulting from the continued use of this codebase.

### Contact

If you discover any bugs or security issues, please report them via [Telegram](https://t.me/PaulRBerg).

## Acknowledgments

- [ds-proxy](https://github.com/dapphub/ds-proxy) - DappHub's proxy, which powers the Maker protocol.
- [dsa-contracts](https://github.com/Instadapp/dsa-contracts) - InstaDapp's DeFi Smart Accounts.

## License

This project is licensed under MIT.

<!-- Links -->

[eip-1014]: https://eips.ethereum.org/EIPS/eip-1014
[frontends]: https://github.com/PaulRBerg/prb-proxy/wiki/Frontends
[se-3667]: https://ethereum.stackexchange.com/questions/3667/difference-between-call-callcode-and-delegatecall/3672
[dsproxy-guide]:
  https://github.com/makerdao/developerguides/blob/9ded1b68228e6cd70885f1326349c6bf087b9573/devtools/working-with-dsproxy/working-with-dsproxy.md
