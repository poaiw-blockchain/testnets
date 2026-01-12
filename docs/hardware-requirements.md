# Hardware Requirements

## Quick Reference

| Component | Light Node | Full Node | Archive Node | Validator |
|-----------|------------|-----------|--------------|-----------|
| **CPU** | 2 cores | 4 cores | 8 cores | 8+ cores |
| **RAM** | 4 GB | 16 GB | 32 GB | 32 GB |
| **Storage** | 50 GB SSD | 200 GB NVMe | 2 TB NVMe | 500 GB NVMe |
| **Network** | 10 Mbps | 100 Mbps | 100 Mbps | 1 Gbps |

## Testnet Requirements

For joining `paw-testnet-1`:

- **CPU**: 4+ cores @ 2.5 GHz (AVX2 required)
- **RAM**: 16 GB minimum
- **Storage**: 200 GB NVMe SSD
- **Network**: 100 Mbps symmetric
- **OS**: Ubuntu 22.04 LTS (recommended)

## Mainnet Requirements

For production validators:

- **CPU**: 8+ cores @ 3.0 GHz (Intel Xeon or AMD EPYC)
- **RAM**: 32 GB ECC
- **Storage**: 500 GB NVMe SSD (enterprise grade)
- **Network**: 1 Gbps symmetric with DDoS protection

## Cloud Provider Examples

| Provider | Instance | vCPU | RAM | Monthly Cost |
|----------|----------|------|-----|--------------|
| AWS | c6i.2xlarge | 8 | 16 GB | ~$190 |
| GCP | c2-standard-8 | 8 | 32 GB | ~$230 |
| Hetzner | CCX23 | 8 | 32 GB | ~$78 |
| DigitalOcean | c-8 | 8 | 16 GB | ~$210 |

## Storage Growth

- Testnet: ~5 GB/month
- Mainnet (projected): ~15 GB/month
- Archive nodes: Use pruning strategy `nothing`

## Software Prerequisites

```bash
# Ubuntu 22.04
sudo apt update && sudo apt install -y \
  build-essential git curl jq lz4

# Go 1.24+
wget https://go.dev/dl/go1.24.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.24.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/bin/go/bin:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc
```

## Full Documentation

See [VALIDATOR_HARDWARE_REQUIREMENTS.md](https://github.com/poaiw-blockchain/paw/blob/main/docs/VALIDATOR_HARDWARE_REQUIREMENTS.md) for detailed specifications.
