# PAW MVP-1 Testnet Architecture

**Chain ID:** `paw-mvp-1`
**Last Updated:** 2026-01-14

## Network Topology

```
                              Internet
                                 │
                    ┌────────────┴────────────┐
                    │       Cloudflare        │
                    │    (DDoS Protection)    │
                    └────────────┬────────────┘
                                 │
           ┌─────────────────────┼─────────────────────┐
           │                     │                     │
    ┌──────▼──────┐       ┌──────▼──────┐       ┌──────▼──────┐
    │   Nginx     │       │   Nginx     │       │   Nginx     │
    │  (RPC/API)  │       │  (Explorer) │       │  (Faucet)   │
    └──────┬──────┘       └──────┬──────┘       └──────┬──────┘
           │                     │                     │
           └─────────────────────┼─────────────────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
       ┌──────▼──────┐    ┌──────▼──────┐   ┌──────▼──────┐
       │  Sentry 1   │    │  Sentry 2   │   │  Services   │
       │ paw-testnet │    │  services-  │   │  (Explorer, │
       │ 54.39.103.49│    │   testnet   │   │   Faucet)   │
       │  P2P:12056  │    │139.99.149.160│  │             │
       └──────┬──────┘    └──────┬──────┘   └─────────────┘
              │                  │
              └────────┬─────────┘
                       │
         ┌─────────────┼─────────────┐
         │     WireGuard VPN        │
         │      (10.10.0.x)         │
         └─────────────┬─────────────┘
                       │
    ┌──────────────────┼──────────────────┐
    │                  │                  │
    ▼                  ▼                  ▼
┌─────────┐      ┌─────────┐      ┌─────────────────┐
│ Val 1&2 │      │ Val 3&4 │      │                 │
│paw-test │◄────►│services │      │  Future Vals    │
│   net   │ VPN  │ testnet │      │  (Community)    │
└─────────┘      └─────────┘      └─────────────────┘
```

## Server Infrastructure

### paw-testnet (54.39.103.49 / 10.10.0.2)

**Role:** Primary validator server + Sentry 1

| Node | Type | P2P Port | RPC Port | gRPC Port | REST Port | Node ID |
|------|------|----------|----------|-----------|-----------|---------|
| val1 | Validator | 11656 | 11657 | 11090 | 11317 | `945dfd111e231525f722a32d24de0da28dade0e8` |
| val2 | Validator | 11756 | 11757 | 11190 | 11417 | `35c1a40debd4a455a37a56cee7adbaaffb0778f8` |
| sentry1 | Sentry | 12056 | 12057 | 12090 | 12017 | `38510c172e324f25e6fe8d9938d713bcaed924af` |

**Services:**
- Explorer API: Port 11080
- Faucet API: Port 11084
- WebSocket Proxy: Port 11082/11083

### services-testnet (139.99.149.160 / 10.10.0.4)

**Role:** Secondary validator server + Sentry 2

| Node | Type | P2P Port | RPC Port | gRPC Port | REST Port | Node ID |
|------|------|----------|----------|-----------|-----------|---------|
| val3 | Validator | 11856 | 11857 | 11290 | 11517 | `a2b9ab78b0be7f006466131b44ede9a02fc140c4` |
| val4 | Validator | 11956 | 11957 | 11390 | 11617 | `f8187d5bafe58b78b00d73b0563b65ad8c0d5fda` |
| sentry2 | Sentry | 12056 | 12057 | 12090 | 12017 | `ce6afbda0a4443139ad14d2b856cca586161f00d` |

## Public Endpoints

### Primary Endpoints (paw-testnet / sentry1)

| Service | URL | Backend |
|---------|-----|---------|
| RPC | https://testnet-rpc.poaiw.org | Sentry1 RPC :12057 |
| REST API | https://testnet-api.poaiw.org | Sentry1 REST :12017 |
| gRPC | testnet-grpc.poaiw.org:443 | Sentry1 gRPC :12090 |
| WebSocket | wss://testnet-ws.poaiw.org | WebSocket Proxy |

### Secondary Endpoints (services-testnet / sentry2)

| Service | URL | Backend |
|---------|-----|---------|
| RPC | https://testnet-rpc-2.poaiw.org | Sentry2 RPC :12057 |
| REST API | https://testnet-api-2.poaiw.org | Sentry2 REST :12017 |

### Services

| Service | URL | Backend |
|---------|-----|---------|
| Explorer (Ping.pub) | https://explorer.poaiw.org/paw | Static /var/www/ping-explorer |
| Legacy Explorer | https://testnet-explorer.poaiw.org | Explorer service |
| Faucet | https://testnet-faucet.poaiw.org | Faucet service |

## Peer Configuration

### For External Nodes (Community Validators)

Connect ONLY to sentry nodes. Validators are not publicly exposed:

```bash
PEERS="38510c172e324f25e6fe8d9938d713bcaed924af@54.39.103.49:12056,ce6afbda0a4443139ad14d2b856cca586161f00d@139.99.149.160:12056"
```

### For Internal Validators

Validators communicate via WireGuard VPN (10.10.0.x network):

- Val1/Val2 peer with Val3/Val4 via `10.10.0.4:11856`, `10.10.0.4:11956`
- Val3/Val4 peer with Val1/Val2 via `10.10.0.2:11656`, `10.10.0.2:11756`
- Sentries peer with all validators on VPN

### Sentry Configuration

Sentries use `private_peer_ids` to prevent gossipping validator addresses:

```toml
# config.toml on sentry nodes
pex = true
private_peer_ids = "945dfd111e231525f722a32d24de0da28dade0e8,35c1a40debd4a455a37a56cee7adbaaffb0778f8,a2b9ab78b0be7f006466131b44ede9a02fc140c4,f8187d5bafe58b78b00d73b0563b65ad8c0d5fda"
```

## Systemd Services

### paw-testnet

```bash
# Validator services (templated)
pawd-val@1.service  # Val1
pawd-val@2.service  # Val2
pawd-sentry@1.service  # Sentry1

# Supporting services
paw-explorer.service
paw-faucet-full.service
paw-websocket-proxy.service
```

### services-testnet

```bash
# Validator services (templated)
pawd-val@3.service  # Val3
pawd-val@4.service  # Val4
pawd-sentry.service  # Sentry2 (legacy naming)
```

## Genesis Validators

The genesis file includes 2 initial validators with equal voting power:

| Validator | Address | Power |
|-----------|---------|-------|
| val1 | `1B4874314C3BD856591225CA6930FE8A174E2428` | 50000 |
| val2 | `8EA6C77BEA80ABEC52E9E158A48641A8646ED7F2` | 50000 |

Val3 and Val4 were added post-genesis via staking transactions.

## Security Model

1. **Validators Hidden**: No validator P2P ports exposed to internet
2. **Sentry Protection**: All public traffic routes through sentry nodes
3. **VPN Isolation**: Validator-to-validator communication over WireGuard
4. **Private Peer IDs**: Sentries never gossip validator addresses
5. **Rate Limiting**: Cloudflare DDoS protection on all endpoints
6. **Firewall**: UFW restricts access to required ports only

## Health Monitoring

Health check scripts run every 5 minutes on both servers:

```bash
# Check all node heights
for port in 11657 11757 11857 11957 12057; do
  curl -s http://127.0.0.1:$port/status | jq -r '.result.sync_info.latest_block_height'
done
```

Prometheus metrics exposed on:
- Validators: Port 11660, 11760, 11860, 11960
- Sentries: Port 12060

## Module Status

| Module | Status | Notes |
|--------|--------|-------|
| auth, bank, staking | Enabled | Core modules |
| gov, distribution | Enabled | Governance active |
| ibc, transfer | Enabled | IBC operational |
| **dex** | Disabled | Enable via governance |
| **compute** | Disabled | Enable via governance |
| **oracle** | Disabled | Enable via governance |
