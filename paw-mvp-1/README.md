# PAW MVP Testnet (paw-mvp-1)

MVP release testnet with core IBC functionality. DEX, Compute, and Oracle modules are disabled at genesis.

## Quick Start

```bash
# Download binary
curl -LO https://artifacts.poaiw.org/mvp/v1.0.0-mvp/pawd-linux-amd64
chmod +x pawd-linux-amd64
mv pawd-linux-amd64 pawd

# Initialize node
./pawd init my-node --chain-id paw-mvp-1

# Download genesis
curl -LO https://artifacts.poaiw.org/mvp/genesis.json
mv genesis.json ~/.paw/config/genesis.json

# Configure peers (connect to sentry nodes, NOT validators directly)
PEERS="38510c172e324f25e6fe8d9938d713bcaed924af@54.39.103.49:12056,ce6afbda0a4443139ad14d2b856cca586161f00d@139.99.149.160:12056"
sed -i "s/^persistent_peers = .*/persistent_peers = \"$PEERS\"/" ~/.paw/config/config.toml

# Start node
./pawd start
```

## Endpoints

### Primary Endpoints (paw-testnet / sentry1)

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.poaiw.org |
| REST | https://testnet-api.poaiw.org |
| gRPC | testnet-grpc.poaiw.org:443 |

### Secondary Endpoints (services-testnet / sentry2)

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc-2.poaiw.org |
| REST | https://testnet-api-2.poaiw.org |

### Services

| Service | URL |
|---------|-----|
| Explorer (Ping.pub) | https://explorer.poaiw.org/paw |
| Legacy Explorer | https://testnet-explorer.poaiw.org |
| Faucet | https://testnet-faucet.poaiw.org |

## Faucet

Request testnet tokens:
```bash
curl -X POST https://testnet-faucet.poaiw.org/request \
  -H "Content-Type: application/json" \
  -d '{"address": "paw1..."}'
```

## MVP Module Status

| Module | Status | Description |
|--------|--------|-------------|
| auth | Enabled | Account management |
| bank | Enabled | Token transfers |
| staking | Enabled | Validator staking |
| slashing | Enabled | Validator penalties |
| distribution | Enabled | Reward distribution |
| gov | Enabled | Governance proposals |
| ibc | Enabled | Inter-blockchain communication |
| transfer | Enabled | IBC token transfers |
| **dex** | **Disabled** | Enable via governance |
| **compute** | **Disabled** | Enable via governance |
| **oracle** | **Disabled** | Enable via governance |

## Enabling Disabled Modules

After MVP stability is confirmed, modules can be enabled via governance:

```bash
# Submit proposal to enable DEX
pawd tx gov submit-proposal param-change \
  --title "Enable DEX Module" \
  --description "Enable DEX for trading" \
  --changes '[{"subspace":"dex","key":"Enabled","value":"true"}]' \
  --from validator \
  --chain-id paw-mvp-1
```

See `docs/governance/MODULE_ENABLE_GOVERNANCE.md` for details.

## Resources

- [Transition Plan](../MVP_TESTNET_TRANSITION_PLAN.md)
- [MVP Conformance Status](../../MVP_CONFORMANCE_STATUS.md)
- [Module Enable Governance](../../paw/docs/governance/MODULE_ENABLE_GOVERNANCE.md)
