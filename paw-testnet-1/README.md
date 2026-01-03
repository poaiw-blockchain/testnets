# PAW Devnet (paw-testnet-1)

Development network for the PAW blockchain. Access is limited to approved developers and contributors.

## Chain Information

| Property | Value |
|----------|-------|
| Chain ID | `paw-testnet-1` |
| Genesis Time | 2025-12-31T08:20:09Z |
| Native Denom | `upaw` |
| Binary | `pawd` |

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

## Quick Start

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

## Artifacts

Genesis and configuration files are also available at:
https://artifacts.poaiw.org

## Faucet

Contact the PAW team for devnet tokens.
