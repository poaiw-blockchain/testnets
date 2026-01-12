# paw-testnet-1

**Chain ID:** `paw-testnet-1`
**Status:** Active
**Denom:** upaw (display: paw, 6 decimals)
**Genesis SHA256:** `b149e5aa1869973bdcedcb808c340e97d3b0c951cb1243db901d84d3b3f659b5`

[Website](https://poaiw.org) | [Discord](https://discord.gg/poaiw) | [Twitter](https://twitter.com/poaiw_blockchain) | [GitHub](https://github.com/poaiw-blockchain)

## Public Endpoints

| Service | URL | Provider |
|---------|-----|----------|
| RPC | https://testnet-rpc.poaiw.org | PAW Foundation |
| REST API | https://testnet-api.poaiw.org | PAW Foundation |
| gRPC | testnet-grpc.poaiw.org:443 | PAW Foundation |
| WebSocket | wss://testnet-ws.poaiw.org | PAW Foundation |
| Prometheus Metrics | https://testnet-rpc.poaiw.org:11660/metrics | PAW Foundation |
| Explorer | https://testnet-explorer.poaiw.org | PAW Foundation |
| Faucet | https://testnet-faucet.poaiw.org | PAW Foundation |

## Quick Start

```bash
# Initialize
pawd init my-node --chain-id paw-testnet-1

# Download genesis
curl -sL https://raw.githubusercontent.com/poaiw-blockchain/testnets/main/paw-testnet-1/genesis.json > ~/.paw/config/genesis.json

# Configure seeds
SEEDS="f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656"
sed -i "s/^seeds *=.*/seeds = \"$SEEDS\"/" ~/.paw/config/config.toml

# Start
pawd start --minimum-gas-prices 0.001upaw
```

## Sync Methods

| Method | Guide |
|--------|-------|
| State-Sync | [state_sync.md](./state_sync.md) |
| Snapshot | [SNAPSHOTS.md](./SNAPSHOTS.md) |
| Genesis | See Quick Start above |

## Peering

**Seeds:**
```
f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656
```

**Persistent Peers:** See [peers.txt](./peers.txt)

**State-sync RPC:**
```
testnet-rpc.poaiw.org:443
```

**Address Book:**
```bash
curl -sL https://artifacts.poaiw.org/paw-testnet-1/addrbook.json > ~/.paw/config/addrbook.json
```

## Useful Commands

```bash
# Check sync status
curl -s https://testnet-rpc.poaiw.org/status | jq '.result.sync_info'

# Get latest block
curl -s https://testnet-rpc.poaiw.org/block | jq '.result.block.header.height'

# Check connected peers
curl -s https://testnet-rpc.poaiw.org/net_info | jq '.result.n_peers'
```

## Get Testnet Tokens

Visit: https://testnet-faucet.poaiw.org

## Files

| File | Description |
|------|-------------|
| [genesis.json](./genesis.json) | Chain genesis |
| [chain.json](./chain.json) | Chain registry metadata |
| [endpoints.json](./endpoints.json) | Machine-readable endpoints |
| [peers.txt](./peers.txt) | Persistent peers |
| [seeds.txt](./seeds.txt) | Seed nodes |
| [state_sync.md](./state_sync.md) | State-sync guide |
| [SNAPSHOTS.md](./SNAPSHOTS.md) | Snapshot guide |
