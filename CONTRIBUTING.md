# Contributing to PAW Testnets

Thank you for your interest in contributing to the PAW testnet configurations!

## What This Repository Contains

This repository contains network configurations for PAW testnets:

- Genesis files (`genesis.json`)
- Chain registry metadata (`chain.json`, `assetlist.json`)
- Peer and seed node information (`peers.txt`, `seeds.txt`)
- IBC channel configurations

## How to Contribute

### Adding Your Validator/Node as a Peer

1. Fork this repository
2. Add your peer information to `paw-mvp-1/peers.txt`:
   ```
   <node_id>@<ip>:<port>
   ```
3. Submit a pull request with:
   - Your node ID and connection info
   - A brief description of your infrastructure

### Submitting Genesis Transactions

For new testnets requiring gentx submissions:

1. Generate your gentx using the instructions in the network README
2. Place your gentx file in `<network>/gentxs/gentx-<moniker>.json`
3. Submit a pull request

### Updating Chain Registry Metadata

If you need to update `chain.json` or `assetlist.json`:

1. Ensure your changes follow the [Chain Registry schema](https://github.com/cosmos/chain-registry)
2. Test that your JSON is valid
3. Submit a pull request explaining the changes

### Reporting Network Issues

For issues related to network configuration (not code bugs):

- Incorrect peer information
- Genesis file problems
- IBC channel issues

Use the GitHub issue templates provided.

## Guidelines

- **Test before submitting**: Validate JSON files and verify peer connectivity
- **Keep commits focused**: One change per pull request when possible
- **Follow existing format**: Match the style of existing configuration files
- **Be responsive**: Address review feedback promptly

## Code Issues

For bugs in the PAW blockchain code itself, please submit issues to the
[main PAW repository](https://github.com/poaiw-blockchain/paw).

## Questions?

- Open a GitHub Discussion
- Join our Discord community
- Email: info@poaiw.org

## License

By contributing, you agree that your contributions will be licensed under the
Apache License 2.0.
