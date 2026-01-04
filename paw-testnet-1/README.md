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

## Public Artifacts

All artifacts available at: **https://artifacts.poaiw.org**

| File | URL | Description |
|------|-----|-------------|
| genesis.json | [Download](https://artifacts.poaiw.org/genesis.json) | Genesis file (required) |
| peers.txt | [Download](https://artifacts.poaiw.org/peers.txt) | Persistent peer list |
| seeds.txt | [Download](https://artifacts.poaiw.org/seeds.txt) | Seed nodes |
| addrbook.json | [Download](https://artifacts.poaiw.org/addrbook.json) | Address book |
| chain.json | [Download](https://artifacts.poaiw.org/chain.json) | Chain registry metadata |

## Public Endpoints

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.poaiw.org |
| REST API | https://testnet-api.poaiw.org |
| gRPC | testnet-grpc.poaiw.org:443 |
| WebSocket | wss://testnet-ws.poaiw.org |
| Explorer | https://testnet-explorer.poaiw.org |
| Faucet | https://testnet-faucet.poaiw.org |

## Peers

```
0aa94130db435f9f46c2f1d295d45ebf6da89e02@54.39.103.49:26656
```

## Quick Start

### 1. Install Binary

```bash
git clone https://github.com/poaiw-blockchain/paw.git
cd paw
make install
```

### 2. Initialize Node

```bash
pawd init <your-moniker> --chain-id paw-testnet-1
```

### 3. Download Genesis

```bash
curl -o ~/.paw/config/genesis.json https://artifacts.poaiw.org/genesis.json
```

### 4. Configure Peers

```bash
PEERS="0aa94130db435f9f46c2f1d295d45ebf6da89e02@54.39.103.49:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.paw/config/config.toml
```

### 5. Start Node

```bash
pawd start
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

## Become a Contributor

For validator access or development contribution:

1. **GitHub** - [Submit a Devnet Access Request](https://github.com/poaiw-blockchain/testnets/issues/new?template=devnet-access.yml)
2. **Email** - dev@poaiw.org
3. **Discord** - [discord.gg/paw](https://discord.gg/paw)

## Resources

- [PAW Core Repository](https://github.com/poaiw-blockchain/paw)
- [Documentation](https://testnet-docs.poaiw.org)
- [Block Explorer](https://testnet-explorer.poaiw.org)
