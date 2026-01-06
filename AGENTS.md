# PAW Testnets Repository

## Repository Separation

**This repo (`paw-testnets/`)** → github:poaiw-blockchain/testnets (network config)
**Main repo (`paw/`)** → github:poaiw-blockchain/paw (source code)

### Save HERE (paw-testnets/<chain-id>/)
- genesis.json - network genesis file
- chain.json - chain registry metadata
- assetlist.json - token metadata
- versions.json - upgrade history
- peers.txt, seeds.txt - node addresses
- config/app.toml, config/config.toml - reference configs
- SNAPSHOTS.md, state_sync.md, IBC.md - sync/IBC guides
- _IBC/*.json - IBC channel metadata
- README.md - network-specific docs
- bin/SHA256SUMS - binary checksums

### Save to MAIN REPO (paw/)
- Go source code, modules (compute, dex, oracle), CLI
- Protobuf definitions
- Tests, Makefiles, Dockerfiles
- General documentation

## Health Check
Run `~/blockchain-projects/scripts/testnet-health-check.sh` for all testnets.

## Port Configuration (PAW Testnet - Port Range 11000-11999)

**4-Validator Setup** with staged deployment (2→3→4 validators)

### Validator Ports (paw-testnet / 10.10.0.2)
| Validator | RPC | P2P | gRPC | REST | Prometheus |
|-----------|-----|-----|------|------|------------|
| Val 1 | 11657 | 11656 | 11090 | 11317 | 11660 |
| Val 2 | 11757 | 11756 | 11190 | 11417 | 11760 |

### Validator Ports (services-testnet / 10.10.0.4)
| Validator | RPC | P2P | gRPC | REST | Prometheus |
|-----------|-----|-----|------|------|------------|
| Val 3 | 11857 | 11856 | 11290 | 11517 | 11860 |
| Val 4 | 11957 | 11956 | 11390 | 11617 | 11960 |

### Public Endpoints
| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.poaiw.org |
| REST API | https://testnet-api.poaiw.org |
| gRPC | testnet-grpc.poaiw.org:443 |
| Explorer | https://testnet-explorer.poaiw.org |
| Faucet | https://testnet-faucet.poaiw.org |

### Service Ports
| Service | Port |
|---------|------|
| Explorer API | 11080 |
| Faucet API | 11081 |
| WS Proxy | 11082 |
| GraphQL | 11400 |
| cosmos-exporter | 11300 |

See `paw-testnet-1/TESTNET_SETUP.md` for full deployment checklist.
