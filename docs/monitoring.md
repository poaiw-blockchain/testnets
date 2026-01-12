# PAW Testnet Monitoring

## Prometheus Metrics

PAW nodes expose Prometheus metrics for monitoring chain state, network health, and performance.

### Public Metrics Endpoint

```
https://testnet-rpc.poaiw.org:11660/metrics
```

### Enable Metrics on Your Node

Edit `~/.paw/config/config.toml`:

```toml
[instrumentation]
prometheus = true
prometheus_listen_addr = ":26660"
```

Restart your node after changes.

### Key Metrics

| Metric | Description |
|--------|-------------|
| `cometbft_consensus_height` | Current block height |
| `cometbft_consensus_validators` | Number of validators |
| `cometbft_p2p_peers` | Connected peer count |
| `cometbft_mempool_size` | Pending transactions |
| `cometbft_consensus_block_interval_seconds` | Block time |

### Scrape with Prometheus

```yaml
scrape_configs:
  - job_name: 'paw-testnet'
    static_configs:
      - targets: ['localhost:26660']
    metrics_path: /metrics
```

## RPC Health Checks

```bash
# Health check
curl -s https://testnet-rpc.poaiw.org/health

# Node status
curl -s https://testnet-rpc.poaiw.org/status | jq '.result.sync_info'

# Peer count
curl -s https://testnet-rpc.poaiw.org/net_info | jq '.result.n_peers'
```

## Grafana Dashboard

Import Cosmos SDK dashboards from [Grafana Labs](https://grafana.com/grafana/dashboards/) using dashboard IDs:
- CometBFT: 11036
- Cosmos SDK: 11037

## Alerting

Recommended alerts:
- Block height not increasing (>30s)
- Peer count < 3
- Node catching up for extended period
- Memory/CPU threshold exceeded
