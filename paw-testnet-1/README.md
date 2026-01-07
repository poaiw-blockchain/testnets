# paw-testnet-1

**Chain ID:** paw-testnet-1
**Denom:** upaw (display: paw, 6 decimals)
**Genesis SHA256:** b149e5aa1869973bdcedcb808c340e97d3b0c951cb1243db901d84d3b3f659b5

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
pawd start
```

## Sync Methods

| Method | Time | Guide |
|--------|------|-------|
| State-Sync | ~5 min | [state_sync.md](./state_sync.md) |
| Snapshot | ~30 min | [SNAPSHOTS.md](./SNAPSHOTS.md) |
| Genesis | Hours | See Quick Start above |

## Public Endpoints

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.poaiw.org |
| REST API | https://testnet-api.poaiw.org |
| gRPC | testnet-grpc.poaiw.org:443 |
| Explorer | https://testnet-explorer.poaiw.org |
| Faucet | https://testnet-faucet.poaiw.org |
| Files | https://testnet-rpc.poaiw.org/files/ |

## Seeds & Peers

**Seed:**
```
f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656
```

**Peers:** See [peers.txt](./peers.txt)

## Get Testnet Tokens

Visit: https://testnet-faucet.poaiw.org

## Files

| File | Description |
|------|-------------|
| [genesis.json](./genesis.json) | Chain genesis |
| [peers.txt](./peers.txt) | Persistent peers |
| [seeds.txt](./seeds.txt) | Seed nodes |
| [state_sync.md](./state_sync.md) | State-sync guide |
| [SNAPSHOTS.md](./SNAPSHOTS.md) | Snapshot guide |
