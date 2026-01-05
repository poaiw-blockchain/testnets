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
