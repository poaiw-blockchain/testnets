# paw-testnet-1

**Chain ID:** paw-testnet-1
**Denom:** upaw (display: paw, 6 decimals)
**Genesis SHA256:** b149e5aa1869973bdcedcb808c340e97d3b0c951cb1243db901d84d3b3f659b5

## Quick Start

```bash
curl -sL https://raw.githubusercontent.com/poaiw-blockchain/testnets/main/paw-testnet-1/install.sh | bash
```

## Manual Installation

### Prerequisites

- Ubuntu 22.04+
- 4 CPU / 8GB RAM / 200GB SSD
- Go 1.21+ (if building from source)

### Option 1: State-Sync (Fast, ~5 min)

See [state_sync.md](./state_sync.md)

### Option 2: Snapshot (Medium, ~30 min)

See [SNAPSHOTS.md](./SNAPSHOTS.md)

### Option 3: Genesis Sync (Full History)

```bash
# Download binary
curl -sL https://github.com/poaiw-blockchain/paw/releases/latest/download/pawd_linux_amd64 -o pawd
chmod +x pawd && sudo mv pawd /usr/local/bin/

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

## Public Endpoints

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.poaiw.org |
| REST API | https://testnet-api.poaiw.org |
| gRPC | testnet-grpc.poaiw.org:443 |
| Explorer | https://testnet-explorer.poaiw.org |
| Faucet | https://testnet-faucet.poaiw.org |
| Snapshots | https://testnet-rpc.poaiw.org/files/snapshots/ |

## Seeds & Peers

**Seeds:**
```
f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656
```

**Persistent Peers:**
```
f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656,4d4ab236a6ab88eafe5a3745cc3a00c39cfe227a@54.39.103.49:11756,6dd222b005b7fa30d805d694cc1cd98276d7a976@139.99.149.160:11856,97801086479686da8ba49a8e3e0d1d4e4179abf1@139.99.149.160:11956
```

## Get Testnet Tokens

Visit: https://testnet-faucet.poaiw.org

## Useful Commands

```bash
# Check sync status
pawd status | jq .SyncInfo

# Check peer count
curl -s localhost:26657/net_info | jq '.result.n_peers'

# View logs
sudo journalctl -u pawd -f
```

## Files

| File | Description |
|------|-------------|
| [genesis.json](./genesis.json) | Chain genesis |
| [peers.txt](./peers.txt) | Persistent peers |
| [seeds.txt](./seeds.txt) | Seed nodes |
| [chain.json](./chain.json) | Chain registry metadata |
| [assetlist.json](./assetlist.json) | Token metadata |
| [state_sync.md](./state_sync.md) | State-sync guide |
| [SNAPSHOTS.md](./SNAPSHOTS.md) | Snapshot guide |
