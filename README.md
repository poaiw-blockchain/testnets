# PAW Testnets

Genesis files, configuration, and documentation for PAW blockchain networks.

## Quick Start

```bash
curl -sL https://raw.githubusercontent.com/poaiw-blockchain/testnets/main/scripts/install.sh | bash
```

Or see [Join Testnet Guide](./docs/join-testnet.md) for manual installation.

## Active Networks

| Network | Chain ID | Status | Genesis |
|---------|----------|--------|---------|
| [paw-mvp-1](./paw-mvp-1/) | `paw-mvp-1` | Active | [genesis.json](./paw-mvp-1/genesis.json) |

## Public Endpoints

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.poaiw.org |
| REST API | https://testnet-api.poaiw.org |
| gRPC | testnet-grpc.poaiw.org:443 |
| WebSocket | wss://testnet-ws.poaiw.org |
| Explorer | https://testnet-explorer.poaiw.org |
| Faucet | https://testnet-faucet.poaiw.org |
| Snapshots | https://snapshots.poaiw.org |
| Artifacts | https://artifacts.poaiw.org |

## Documentation

### Getting Started

| Guide | Description |
|-------|-------------|
| [Join Testnet](./docs/join-testnet.md) | Quick start and sync methods |
| [Hardware Requirements](./docs/hardware-requirements.md) | System specifications |
| [Configuration](./docs/configuration.md) | Node configuration reference |

### Node Operations

| Guide | Description |
|-------|-------------|
| [Becoming a Validator](./docs/becoming-a-validator.md) | Validator setup guide |
| [Monitoring](./docs/monitoring.md) | Prometheus/Grafana setup |
| [Troubleshooting](./docs/troubleshooting.md) | Common issues and fixes |
| [Public Endpoints](./docs/public-endpoints.md) | Endpoint documentation |

## Artifacts

| Resource | URL |
|----------|-----|
| Genesis | https://artifacts.poaiw.org/paw-mvp-1/genesis.json |
| Peers | https://artifacts.poaiw.org/paw-mvp-1/peers.txt |
| Address Book | https://artifacts.poaiw.org/paw-mvp-1/addrbook.json |
| Latest Snapshot | https://snapshots.poaiw.org/paw-mvp-1/latest.tar.lz4 |

## Resources

- [PAW Source Code](https://github.com/poaiw-blockchain/paw)
- [PAW Documentation](https://github.com/poaiw-blockchain/paw/tree/main/docs)
- [Discord](https://discord.gg/poaiw)
- [Twitter](https://twitter.com/poaiw_blockchain)

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## License

Apache 2.0 - see [LICENSE](./LICENSE)
