# PAW Testnet Server - AI Agent Instructions

## Server Identity
- **Hostname**: paw-testnet
- **IP**: 54.39.103.49
- **VPN IP**: 10.10.0.2
- **Role**: Primary PAW testnet validators (val1, val2) + services

## Full Permissions Granted

AI agents have FULL permissions for E2E testing operations:

### Bash/Shell
- Execute any bash commands
- Run systemctl commands (start, stop, restart, status)
- Manage validator services (pawd-val@1, pawd-val@2)
- Run curl, jq, and other CLI tools

### File Operations
- Read/write any file in /home/ubuntu
- Read validator configs in ~/.paw-val1 and ~/.paw-val2
- Write test results and reports
- Create/modify scripts in ~/testnets/

### Network
- Make HTTP requests to localhost ports (11657, 11757, 11317, 11417)
- Access faucet (8082), explorer (11080) services

### Go
- Build and run Go binaries
- Execute E2E test framework

## Validator Configuration

| Validator | Home | RPC | REST | gRPC | P2P |
|-----------|------|-----|------|------|-----|
| val1 | ~/.paw-val1 | 11657 | 11317 | 11090 | 11656 |
| val2 | ~/.paw-val2 | 11757 | 11417 | 11190 | 11756 |

Remote validators (via SSH to services-testnet):
| Validator | Home | RPC | REST | gRPC | P2P |
|-----------|------|-----|------|------|-----|
| val3 | ~/.paw-val3 | 11857 | 11517 | 11290 | 11856 |
| val4 | ~/.paw-val4 | 11957 | 11617 | 11390 | 11956 |

## Services

| Service | Port | Systemd Unit |
|---------|------|--------------|
| Validator 1 | 11657 | pawd-val@1 |
| Validator 2 | 11757 | pawd-val@2 |
| Faucet | 8082 | paw-faucet |
| Explorer | 11080 | paw-explorer |

## Quick Commands

```bash
# Check validator status
curl -s http://127.0.0.1:11657/status | jq '.result.sync_info'

# Get block height
curl -s http://127.0.0.1:11657/status | jq -r '.result.sync_info.latest_block_height'

# Query bank supply
curl -s http://127.0.0.1:11317/cosmos/bank/v1beta1/supply

# Query DEX pools
curl -s http://127.0.0.1:11317/paw/dex/v1beta1/pools

# Restart validator
sudo systemctl restart pawd-val@1
```

## E2E Testing

```bash
# Run validation tests (standalone, no SSH required)
cd ~/testnets/paw-testnet-1/e2e_testnet
./e2e_runner -all -v

# Run with full network (requires SSH to services-testnet)
./e2e_runner -all -v -full
```

## Test Results Location

Results saved to: `~/testnets/paw-testnet-1/results/VALIDATION-*.md`

## Troubleshooting

| Issue | Command |
|-------|---------|
| Validator not signing | `sudo systemctl restart pawd-val@1` |
| Height stuck | Check all 4 validators are up |
| View logs | `journalctl -u pawd-val@1 -f` |
