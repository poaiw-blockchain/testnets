# Join PAW Testnet

**Chain ID:** `paw-mvp-1`

## Quick Start (Recommended)

One-command installation:

```bash
curl -sL https://raw.githubusercontent.com/poaiw-blockchain/testnets/main/scripts/install.sh | bash
```

This script will:
1. Install dependencies (Go, build tools)
2. Build `pawd` from source
3. Initialize your node
4. Download genesis file
5. Configure peers and state-sync
6. Create systemd service

## Manual Installation

### Prerequisites

- **OS:** Ubuntu 22.04 LTS (recommended)
- **CPU:** 4+ cores
- **RAM:** 16 GB minimum
- **Storage:** 200 GB NVMe SSD
- **Go:** 1.24+

See [hardware-requirements.md](./hardware-requirements.md) for full specs.

### Install Dependencies

```bash
sudo apt update && sudo apt install -y build-essential git curl jq lz4

# Install Go 1.24
wget https://go.dev/dl/go1.24.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.24.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc
```

### Build from Source

```bash
git clone https://github.com/poaiw-blockchain/paw.git
cd paw
make build
sudo mv build/pawd /usr/local/bin/
pawd version
```

### Initialize Node

```bash
pawd init my-node --chain-id paw-mvp-1

# Download genesis
curl -sL https://raw.githubusercontent.com/poaiw-blockchain/testnets/main/paw-mvp-1/genesis.json > ~/.paw/config/genesis.json

# Verify checksum
sha256sum ~/.paw/config/genesis.json
# Expected: b149e5aa1869973bdcedcb808c340e97d3b0c951cb1243db901d84d3b3f659b5
```

### Configure Peers

Connect to public sentry nodes (validators are protected behind sentries):

```bash
# Sentry nodes for external connections
PEERS="38510c172e324f25e6fe8d9938d713bcaed924af@54.39.103.49:12056,ce6afbda0a4443139ad14d2b856cca586161f00d@139.99.149.160:12056"

sed -i "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.paw/config/config.toml
sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0.001upaw"/' ~/.paw/config/app.toml
```

## Sync Methods

### Option 1: State-Sync (Fastest, ~5 minutes)

```bash
RPC="https://testnet-rpc.poaiw.org:443"
LATEST=$(curl -s $RPC/block | jq -r .result.block.header.height)
TRUST_HEIGHT=$((LATEST - 2000))
TRUST_HASH=$(curl -s "$RPC/block?height=$TRUST_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$RPC,$RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$TRUST_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" \
~/.paw/config/config.toml

pawd tendermint unsafe-reset-all --home ~/.paw --keep-addr-book
```

### Option 2: Snapshot (Medium, ~30 minutes)

```bash
# Stop node if running
sudo systemctl stop pawd

# Backup validator state (if validator)
cp ~/.paw/data/priv_validator_state.json ~/.paw/priv_validator_state.json.backup

# Download and extract snapshot
cd ~/.paw
rm -rf data
<<<<<<< Updated upstream
curl -L https://snapshots.poaiw.org/latest.tar.lz4 | lz4 -dc - | tar xf -

# Restore validator state (if validator)
cp ~/.paw/priv_validator_state.json.backup ~/.paw/data/priv_validator_state.json
||||||| Stash base
curl -sL https://snapshots.poaiw.org/paw-testnet-1/latest.tar.lz4 | lz4 -dc | tar -xf -
=======
curl -sL https://snapshots.poaiw.org/paw-mvp-1/latest.tar.lz4 | lz4 -dc | tar -xf -
>>>>>>> Stashed changes

# Start node
sudo systemctl start pawd
```

See [SNAPSHOTS.md](../paw-testnet-1/SNAPSHOTS.md) for more details.

### Option 3: Genesis Sync (Slow, hours-days)

For archive nodes or when other methods fail:

```bash
pawd start --minimum-gas-prices 0.001upaw
```

## Create Systemd Service

```bash
sudo tee /etc/systemd/system/pawd.service > /dev/null <<EOF
[Unit]
Description=PAW Node
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/local/bin/pawd start --home $HOME/.paw
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable pawd
sudo systemctl start pawd
```

## Verify Sync Status

```bash
# Check if syncing
curl -s localhost:26657/status | jq '.result.sync_info'

# Wait until catching_up = false
watch -n5 'curl -s localhost:26657/status | jq ".result.sync_info.catching_up"'

# View logs
journalctl -u pawd -f
```

## Public Endpoints

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.poaiw.org |
| REST API | https://testnet-api.poaiw.org |
| gRPC | testnet-grpc.poaiw.org:443 |
| Explorer | https://testnet-explorer.poaiw.org |
| Faucet | https://testnet-faucet.poaiw.org |

## Get Testnet Tokens

Visit https://testnet-faucet.poaiw.org

## Next Steps

- [Become a Validator](./becoming-a-validator.md)
- [Configuration Reference](./configuration.md)
- [Troubleshooting](./troubleshooting.md)
