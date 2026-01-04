# PAW Testnet (paw-testnet-1)

Development network for the PAW blockchain - a Cosmos SDK chain focused on verifiable AI compute, IBC, and DEX functionality.

## Chain Information

| Property | Value |
|----------|-------|
| Chain ID | `paw-testnet-1` |
| Genesis Time | 2025-12-31T08:20:09Z |
| Native Denom | `upaw` |
| Binary | `pawd` |
| Bech32 Prefix | `paw` |
| Cosmos SDK | v0.50.x |
| Go Version | 1.22+ |

## Hardware Requirements

| Specification | Minimum | Recommended |
|---------------|---------|-------------|
| CPU | 4 cores | 8 cores |
| RAM | 8 GB | 16 GB |
| Disk | 100 GB SSD | 500 GB NVMe |
| Network | 100 Mbps | 1 Gbps |

## Software Requirements

| Software | Version |
|----------|---------|
| Go | 1.22 or higher |
| Make | 4.0+ |
| Git | 2.0+ |
| jq | 1.6+ (for scripts) |

## Pre-built Binaries

Download pre-compiled binaries (recommended for quick setup):

| Platform | Architecture | Download | Checksum |
|----------|--------------|----------|----------|
| Linux | amd64 | [pawd-linux-amd64](https://artifacts.poaiw.org/bin/pawd-linux-amd64) | [SHA256](https://artifacts.poaiw.org/bin/SHA256SUMS) |
| Linux | arm64 | [pawd-linux-arm64](https://artifacts.poaiw.org/bin/pawd-linux-arm64) | [SHA256](https://artifacts.poaiw.org/bin/SHA256SUMS) |
| macOS | amd64 | [pawd-darwin-amd64](https://artifacts.poaiw.org/bin/pawd-darwin-amd64) | [SHA256](https://artifacts.poaiw.org/bin/SHA256SUMS) |
| macOS | arm64 | [pawd-darwin-arm64](https://artifacts.poaiw.org/bin/pawd-darwin-arm64) | [SHA256](https://artifacts.poaiw.org/bin/SHA256SUMS) |

```bash
# Example: Download and install on Linux amd64
curl -L https://artifacts.poaiw.org/bin/pawd-linux-amd64 -o pawd
chmod +x pawd
sudo mv pawd /usr/local/bin/
pawd version
```

## Public Artifacts

All artifacts available at: **https://artifacts.poaiw.org**

| File | URL | Description |
|------|-----|-------------|
| genesis.json | [Download](https://artifacts.poaiw.org/genesis.json) | Genesis file (required) |
| peers.txt | [Download](https://artifacts.poaiw.org/peers.txt) | Persistent peer list |
| seeds.txt | [Download](https://artifacts.poaiw.org/seeds.txt) | Seed nodes |
| addrbook.json | [Download](https://artifacts.poaiw.org/addrbook.json) | Address book |
| chain.json | [Download](https://artifacts.poaiw.org/chain.json) | Chain registry metadata |
| assetlist.json | [Download](https://artifacts.poaiw.org/assetlist.json) | Asset metadata |
| app.toml | [Download](https://artifacts.poaiw.org/config/app.toml) | Example app config |
| config.toml | [Download](https://artifacts.poaiw.org/config/config.toml) | Example node config |

## Snapshots

For faster sync, download a recent snapshot:

| Type | Size | Block Height | Download |
|------|------|--------------|----------|
| Pruned | ~5 GB | Updated daily | [Download](https://artifacts.poaiw.org/snapshots/paw-testnet-1-pruned-latest.tar.lz4) |
| Archive | ~20 GB | Updated weekly | [Download](https://artifacts.poaiw.org/snapshots/paw-testnet-1-archive-latest.tar.lz4) |

```bash
# Download and extract snapshot
curl -L https://artifacts.poaiw.org/snapshots/paw-testnet-1-pruned-latest.tar.lz4 | lz4 -dc - | tar -xf - -C ~/.paw
```

## Public Endpoints

| Service | URL | Status |
|---------|-----|--------|
| RPC | https://testnet-rpc.poaiw.org | [Status](https://status.poaiw.org) |
| REST API | https://testnet-api.poaiw.org | [Swagger](https://testnet-api.poaiw.org/swagger/) |
| gRPC | testnet-grpc.poaiw.org:443 | - |
| WebSocket | wss://testnet-ws.poaiw.org | - |
| Explorer | https://testnet-explorer.poaiw.org | - |
| Faucet | https://testnet-faucet.poaiw.org | - |
| Status Page | https://status.poaiw.org | - |

## API Documentation

- **REST API (Swagger)**: https://testnet-api.poaiw.org/swagger/
- **gRPC Reflection**: Enabled on testnet-grpc.poaiw.org:443
- **Cosmos SDK API Docs**: https://docs.cosmos.network/api

## IBC Connections

PAW testnet is connected to the following chains via IBC:

| Chain | Connection ID | Channel (PAW) | Channel (Remote) | Status |
|-------|---------------|---------------|------------------|--------|
| AURA Testnet | connection-0 | channel-0 | channel-0 | Active |

See [IBC.md](./IBC.md) for detailed IBC channel documentation and relayer configuration.

## Peers

```
0aa94130db435f9f46c2f1d295d45ebf6da89e02@54.39.103.49:26656
```

## Quick Start

### Option A: Pre-built Binary (Recommended)

```bash
# 1. Download binary
curl -L https://artifacts.poaiw.org/bin/pawd-linux-amd64 -o pawd
chmod +x pawd
sudo mv pawd /usr/local/bin/

# 2. Initialize node
pawd init <your-moniker> --chain-id paw-testnet-1

# 3. Download genesis
curl -o ~/.paw/config/genesis.json https://artifacts.poaiw.org/genesis.json

# 4. Download recommended config
curl -o ~/.paw/config/app.toml https://artifacts.poaiw.org/config/app.toml
curl -o ~/.paw/config/config.toml https://artifacts.poaiw.org/config/config.toml

# 5. Start node
pawd start
```

### Option B: Build from Source

```bash
# 1. Install Go 1.22+
# See https://golang.org/doc/install

# 2. Clone and build
git clone https://github.com/poaiw-blockchain/paw.git
cd paw
git checkout v0.1.0
make install

# 3. Verify installation
pawd version
# Expected: v0.1.0

# 4. Continue from step 2 above
```

### Configure Peers

```bash
PEERS="0aa94130db435f9f46c2f1d295d45ebf6da89e02@54.39.103.49:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.paw/config/config.toml
```

## State Sync (Fast Sync)

State sync allows rapid bootstrapping:

```bash
SNAP_RPC="https://testnet-rpc.poaiw.org:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true|" ~/.paw/config/config.toml
sed -i.bak -E "s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"|" ~/.paw/config/config.toml
sed -i.bak -E "s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT|" ~/.paw/config/config.toml
sed -i.bak -E "s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.paw/config/config.toml

pawd tendermint unsafe-reset-all --home ~/.paw --keep-addr-book
pawd start
```

## Get Testnet Tokens

Visit the faucet: https://testnet-faucet.poaiw.org

## Network Status

Check current network status:

- **Status Page**: https://status.poaiw.org
- **Current Block Height**: `curl -s https://testnet-rpc.poaiw.org/status | jq -r .result.sync_info.latest_block_height`
- **Network Info**: `curl -s https://testnet-rpc.poaiw.org/net_info | jq .result.n_peers`

## Become a Contributor

For validator access or development contribution:

1. **GitHub** - [Submit a Devnet Access Request](https://github.com/poaiw-blockchain/testnets/issues/new?template=devnet-access.yml)
2. **Email** - dev@poaiw.org
3. **Discord** - [discord.gg/paw](https://discord.gg/paw)

## Resources

- [PAW Core Repository](https://github.com/poaiw-blockchain/paw)
- [Documentation](https://testnet-docs.poaiw.org)
- [Block Explorer](https://testnet-explorer.poaiw.org)
- [API Swagger](https://testnet-api.poaiw.org/swagger/)
- [Status Page](https://status.poaiw.org)
- [IBC Documentation](./IBC.md)
