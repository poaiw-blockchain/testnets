# Configuration Reference

## Chain Information

| Parameter | Value |
|-----------|-------|
| Chain ID | `paw-mvp-1` |
| Binary | `pawd` |
| Denom | `upaw` (display: PAW, 6 decimals) |
| Min Gas Price | `0.001upaw` |
| Block Time | ~5 seconds |
| Home Directory | `~/.paw` |

## Port Reference

| Service | Default Port | Description |
|---------|--------------|-------------|
| P2P | 26656 | Peer-to-peer networking |
| RPC | 26657 | Tendermint RPC |
| gRPC | 9090 | gRPC queries |
| REST API | 1317 | Cosmos REST API |
| Prometheus | 26660 | Metrics endpoint |

## config.toml Settings

### P2P Configuration

```toml
[p2p]
# Seeds for peer discovery
seeds = "f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656"

# Persistent peers (always connect)
persistent_peers = "f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656"

# Maximum inbound/outbound peers
max_num_inbound_peers = 40
max_num_outbound_peers = 10
```

### State-Sync Configuration

```toml
[statesync]
enable = true
rpc_servers = "https://testnet-rpc.poaiw.org:443,https://testnet-rpc.poaiw.org:443"
trust_height = 0       # Set dynamically
trust_hash = ""        # Set dynamically
trust_period = "168h0m0s"
```

### Consensus Configuration

```toml
[consensus]
timeout_propose = "3s"
timeout_prevote = "1s"
timeout_precommit = "1s"
timeout_commit = "5s"
```

## app.toml Settings

### Minimum Gas Prices

```toml
minimum-gas-prices = "0.001upaw"
```

### Pruning Strategies

```toml
# Default (keeps 100k blocks)
pruning = "default"

# Custom pruning
pruning = "custom"
pruning-keep-recent = "100000"
pruning-interval = "100"

# Archive node (no pruning)
pruning = "nothing"
```

### API Configuration

```toml
[api]
enable = true
swagger = false
address = "tcp://127.0.0.1:1317"

[grpc]
enable = true
address = "0.0.0.0:9090"
```

### State-Sync Snapshots

```toml
[state-sync]
snapshot-interval = 1000
snapshot-keep-recent = 2
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PAW_HOME` | Node home directory | `~/.paw` |
| `PAW_CHAIN_ID` | Chain identifier | - |
| `PAW_KEYRING_BACKEND` | Keyring type | `os` |

## Useful Commands

```bash
# View current config
cat ~/.paw/config/config.toml

# View app config
cat ~/.paw/config/app.toml

# Reset config to defaults
pawd tendermint unsafe-reset-all --home ~/.paw --keep-addr-book

# Check node status
curl -s localhost:26657/status | jq '.result.sync_info'
```
