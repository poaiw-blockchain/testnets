# PAW Testnet Public Endpoints

## Chain Overview

| Property | Value |
|----------|-------|
| Chain ID | `paw-testnet-1` |
| Version | v0.1.0 |
| Status | Active |
| Cosmos SDK | v0.50.14 |
| CometBFT | v0.38.17 |

## Public Endpoints

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.poaiw.org |
| REST API | https://testnet-api.poaiw.org |
| gRPC | testnet-grpc.poaiw.org:443 |
| WebSocket | wss://testnet-ws.poaiw.org |
| Prometheus Metrics | https://testnet-rpc.poaiw.org:11660/metrics |

## Explorer

https://testnet-explorer.poaiw.org

## Faucet

https://testnet-faucet.poaiw.org

## Peering

**State-sync RPC:**
```
testnet-rpc.poaiw.org:443
```

**Seeds:**
```
f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656
```

**Persistent Peers:**
```
f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656
4d4ab236a6ab88eafe5a3745cc3a00c39cfe227a@54.39.103.49:11756
6dd222b005b7fa30d805d694cc1cd98276d7a976@139.99.149.160:11856
97801086479686da8ba49a8e3e0d1d4e4179abf1@139.99.149.160:11956
```

**Address Book:**
```bash
curl -sL https://artifacts.poaiw.org/paw-testnet-1/addrbook.json > ~/.paw/config/addrbook.json
```

## Useful Commands

```bash
# Check sync status
curl -s https://testnet-rpc.poaiw.org/status | jq '.result.sync_info'

# Get latest block height
curl -s https://testnet-rpc.poaiw.org/status | jq -r '.result.sync_info.latest_block_height'

# Check connected peers
curl -s https://testnet-rpc.poaiw.org/net_info | jq '.result.n_peers'

# Get node info
curl -s https://testnet-api.poaiw.org/cosmos/base/tendermint/v1beta1/node_info | jq
```
