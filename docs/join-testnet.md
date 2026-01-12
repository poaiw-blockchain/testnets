# Join PAW Testnet

## Prerequisites

- Go 1.24+
- 4GB RAM minimum
- 100GB SSD storage
- Ubuntu 22.04+ or similar

## Install pawd

```bash
# Clone and build
git clone https://github.com/poaiw-blockchain/paw.git
cd paw
make build

# Verify
./build/pawd version
```

## Initialize Node

```bash
# Initialize (replace my-node with your moniker)
pawd init my-node --chain-id paw-testnet-1

# Download genesis
curl -sL https://raw.githubusercontent.com/poaiw-blockchain/testnets/main/paw-testnet-1/genesis.json > ~/.paw/config/genesis.json

# Verify genesis checksum
sha256sum ~/.paw/config/genesis.json
# Expected: b149e5aa1869973bdcedcb808c340e97d3b0c951cb1243db901d84d3b3f659b5
```

## Configure Peers

```bash
# Set seeds
SEEDS="f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656"
sed -i "s/^seeds *=.*/seeds = \"$SEEDS\"/" ~/.paw/config/config.toml

# Set persistent peers
PEERS="f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656,4d4ab236a6ab88eafe5a3745cc3a00c39cfe227a@54.39.103.49:11756"
sed -i "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.paw/config/config.toml
```

## Configure Gas Prices

```bash
sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0.001upaw"/' ~/.paw/config/app.toml
```

## Start Node

```bash
pawd start
```

## Quick Sync Options

### State-Sync (Recommended)

See [state_sync.md](../paw-testnet-1/state_sync.md) for fastest sync method.

### Snapshot

See [SNAPSHOTS.md](../paw-testnet-1/SNAPSHOTS.md) for snapshot-based sync.

## Verify Sync Status

```bash
curl -s localhost:26657/status | jq '.result.sync_info'
```

Wait until `catching_up` becomes `false`.

## Get Testnet Tokens

Visit https://testnet-faucet.poaiw.org
