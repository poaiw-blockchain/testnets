# PAW Testnet Public Endpoints

## Chain Overview

| Property | Value |
|----------|-------|
| Chain ID | `paw-mvp-1` |
| Version | v1.0.0-mvp |
| Status | Active |
| Cosmos SDK | v0.50.14 |
| CometBFT | v0.38.17 |

**Links**: [Website](https://poaiw.org) | [Discord](https://discord.gg/poaiw) | [GitHub](https://github.com/poaiw-blockchain)

## Public Endpoints

### Primary Endpoints (paw-testnet / sentry1)

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.poaiw.org |
| REST API | https://testnet-api.poaiw.org |
| gRPC | testnet-grpc.poaiw.org:443 |
| WebSocket | wss://testnet-ws.poaiw.org |

### Secondary Endpoints (services-testnet / sentry2)

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc-2.poaiw.org |
| REST API | https://testnet-api-2.poaiw.org |

## Explorer & Tools

| Service | URL |
|---------|-----|
| Explorer (Ping.pub) | https://explorer.poaiw.org/paw |
| Legacy Explorer | https://testnet-explorer.poaiw.org |
| Faucet | https://testnet-faucet.poaiw.org |

## Peering

Connect to sentry nodes (NOT validators directly):

### Persistent Peers
```
38510c172e324f25e6fe8d9938d713bcaed924af@54.39.103.49:12056
ce6afbda0a4443139ad14d2b856cca586161f00d@139.99.149.160:12056
```

**Address Book:**
```bash
curl -sL https://artifacts.poaiw.org/paw-mvp-1/addrbook.json > ~/.paw/config/addrbook.json
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
