# Jigsaw lite

<p align="center">
  <img src="https://github.com/jigsaw-finance/jigsaw-lite/assets/102415071/894b1ec7-dcbd-4b2d-ac5d-0a9d0df26313" alt="jigsaw 2"><br>
  <a href="https://github.com/jigsaw-finance/jigsaw-lite/actions/workflows/test.yml">
    <img src="https://github.com/jigsaw-finance/jigsaw-lite/actions/workflows/test.yml/badge.svg" alt="test">
  </a>
  <a href="https://github.com/jigsaw-finance/jigsaw-lite/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT">
  </a>
  <img alt="GitHub commit activity (branch)" src="https://img.shields.io/github/commit-activity/m/jigsaw-finance/jigsaw-lite">
</p>

 
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg

## Overview

Jigsaw is a CDP-based stablecoin protocol that brings full flexibility and composability to your collateral through the concept of “dynamic collateral”. 
Jigsaw leverages crypto’s unique permissionless composability to enable dynamic collateral in a fully non-custodial way. Dynamic collateral is the missing piece of DeFi for unlocking unparalleled flexibility and capital efficiency by boosting your yield.

At Jigsaw, dynamic collateral is more than just flexible asset management; it's about redefining what it means to harness the power of your assets in DeFi.

For further details, please consult the [documentation](https://jigsaw.gitbook.io/jigsaw-protocol).

## Setup

This project uses [just](https://just.systems/man/en/) to run project-specific commands. Refer to installation instructions [here](https://github.com/casey/just?tab=readme-ov-file#installation).

Project was built using [Foundry](https://book.getfoundry.sh/). Refer to installation instructions [here](https://github.com/foundry-rs/foundry#installation).

```sh
git clone git@github.com:jigsaw-finance/jigsaw-protocol-v1.git
cd jigsaw-lite
forge install
```

## Commands

To make it easier to perform some tasks within the repo, a few commands are available through a justfile:

### Build Commands

| Command         | Action                                           |
| --------------- | ------------------------------------------------ |
| `clean-all`     | Description                                      |
| `install`       | Install the Modules                              |
| `update`        | Update Dependencies                              |
| `build`         | Build                                            |
| `format`        | Format code                                      |
| `remap`         | Update remappings.txt                            |
| `clean`         | Clean artifacts, caches                          |
| `docs`           | Generate documentation for Solidity source files |

### Test Commands

| Command        | Description   |
| -------------- | ------------- |
| `test-all`     | Run all tests |
| `coverage-all` | Run coverage  |

Specific tests can be run using `forge test` conventions, specified in more detail in the Foundry [Book](https://book.getfoundry.sh/reference/forge/forge-test#test-options).

### Deploy Commands

// -- TBU --

## Audit Reports

### Upcoming Release

| Auditor | Report Link                                                        |
| ------- | ------------------------------------------------------------------ |
| | |

---

<p align="center">
</p>
