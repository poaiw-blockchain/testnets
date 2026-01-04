# PAW Devnet (paw-testnet-1)

Development network for the PAW blockchain.

## Become a Contributor

This devnet is for developers interested in long-term contribution to the PAW project. We're building a team of committed contributors to help develop, test, and improve the network before public launch.

### How to Apply

Choose any of the following methods:

1. **GitHub** - [Submit a Devnet Access Request](https://github.com/poaiw-blockchain/testnets/issues/new?template=devnet-access.yml)
2. **Email** - Contact dev@poaiw.org with your background and interest
3. **Discord** - Join [discord.gg/paw](https://discord.gg/paw) and introduce yourself in #devnet-applications

### What We're Looking For

- Developers with blockchain, Cosmos SDK, or IBC experience
- Contributors interested in verifiable AI compute, DEX, or oracle modules
- Long-term commitment to the project
- Validators, node operators, and SDK developers

## Chain Information

| Property | Value |
|----------|-------|
| Chain ID | `paw-testnet-1` |
| Genesis Time | 2025-12-31T08:20:09Z |
| Native Denom | `upaw` |
| Binary | `pawd` |

## Public Resources

These resources are publicly accessible:

| Resource | URL |
|----------|-----|
| Explorer | https://explorer.poaiw.org |
| Artifacts | https://artifacts.poaiw.org |
| Documentation | https://github.com/poaiw-blockchain/paw |

## Endpoints

| Service | URL |
|---------|-----|
| RPC | http://54.39.103.49:26657 |
| REST/LCD | http://54.39.103.49:1317 |
| gRPC | 54.39.103.49:9090 |
| P2P | 54.39.103.49:26656 |

## Peers

```
0aa94130db435f9f46c2f1d295d45ebf6da89e02@54.39.103.49:26656
```

## Quick Start (After Approval)

Once your access request is approved:

### 1. Download genesis

```bash
curl -o ~/.paw/config/genesis.json https://raw.githubusercontent.com/poaiw-blockchain/testnets/main/paw-testnet-1/genesis.json
```

### 2. Set peers

Add to `~/.paw/config/config.toml`:

```toml
persistent_peers = "0aa94130db435f9f46c2f1d295d45ebf6da89e02@54.39.103.49:26656"
```

### 3. Start node

```bash
pawd start --home ~/.paw
```

### 4. Receive tokens

After approval, you'll receive devnet tokens to your provided wallet address.
