# PAW Testnets Repository

**Active Network:** `paw-mvp-1`

## Repository Separation

**This repo (`testnets/`)** → github:poaiw-blockchain/testnets (network config)
**Main repo (`paw/`)** → github:poaiw-blockchain/paw (source code)

### Save HERE (testnets/paw-mvp-1/)
- genesis.json, chain.json, assetlist.json, versions.json
- peers.txt - public sentry peers
- ARCHITECTURE.md - network topology
- README.md - quickstart guide

### Save to MAIN REPO (paw/)
- Go source code, modules, CLI, Protobuf, Tests

## Current Network Status

**Chain ID:** `paw-mvp-1`
**Validators:** 4 active (val1-val4)
**Sentries:** 2 public (sentry1, sentry2)

## Node Configuration

### paw-testnet Server (54.39.103.49 / VPN: 10.10.0.2)

| Node | Type | P2P | RPC | Node ID |
|------|------|-----|-----|---------|
| val1 | Validator | 11656 | 11657 | `945dfd111e231525f722a32d24de0da28dade0e8` |
| val2 | Validator | 11756 | 11757 | `35c1a40debd4a455a37a56cee7adbaaffb0778f8` |
| sentry1 | Sentry | 12056 | 12057 | `38510c172e324f25e6fe8d9938d713bcaed924af` |

### services-testnet Server (139.99.149.160 / VPN: 10.10.0.4)

| Node | Type | P2P | RPC | Node ID |
|------|------|-----|-----|---------|
| val3 | Validator | 11856 | 11857 | `a2b9ab78b0be7f006466131b44ede9a02fc140c4` |
| val4 | Validator | 11956 | 11957 | `f8187d5bafe58b78b00d73b0563b65ad8c0d5fda` |
| sentry2 | Sentry | 12056 | 12057 | `ce6afbda0a4443139ad14d2b856cca586161f00d` |

## Public Peers (For External Nodes)

Connect to SENTRY nodes only (validators are protected):

```
38510c172e324f25e6fe8d9938d713bcaed924af@54.39.103.49:12056
ce6afbda0a4443139ad14d2b856cca586161f00d@139.99.149.160:12056
```

## Public Endpoints

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.poaiw.org |
| REST API | https://testnet-api.poaiw.org |
| gRPC | testnet-grpc.poaiw.org:443 |
| Explorer | https://testnet-explorer.poaiw.org |
| Faucet | https://testnet-faucet.poaiw.org |

## Health Check

```bash
# Quick height check
ssh paw-testnet "curl -s http://127.0.0.1:11657/status | jq -r '.result.sync_info.latest_block_height'"
ssh services-testnet "curl -s http://127.0.0.1:11857/status | jq -r '.result.sync_info.latest_block_height'"
```

See `paw-mvp-1/ARCHITECTURE.md` for full network topology.
