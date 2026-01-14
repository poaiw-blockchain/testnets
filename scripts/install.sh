#!/bin/bash
# PAW Testnet Quick Installer
# Usage: curl -sL https://get.testnet.poaiw.org | bash
set -e

# Configuration
CHAIN_ID="paw-mvp-1"
BINARY="pawd"
HOME_DIR="$HOME/.paw"
SEEDS="f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656"
PEERS="f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656,4d4ab236a6ab88eafe5a3745cc3a00c39cfe227a@54.39.103.49:11756"
RPC="https://testnet-rpc.poaiw.org:443"
GENESIS_URL="https://raw.githubusercontent.com/poaiw-blockchain/testnets/main/paw-mvp-1/genesis.json"
GENESIS_SHA256="b149e5aa1869973bdcedcb808c340e97d3b0c951cb1243db901d84d3b3f659b5"

echo "================================"
echo "  PAW Testnet Quick Installer"
echo "================================"
echo ""

# Check OS
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Error: This script only supports Linux"
    exit 1
fi

# Check architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" ]]; then
    echo "Error: Only x86_64 architecture is supported"
    exit 1
fi

# Install dependencies
echo "[1/7] Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq curl git build-essential jq lz4 > /dev/null

# Check for Go
if ! command -v go &> /dev/null; then
    echo "[2/7] Installing Go 1.24..."
    wget -q https://go.dev/dl/go1.24.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go1.24.linux-amd64.tar.gz
    rm go1.24.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
else
    echo "[2/7] Go already installed: $(go version)"
fi

# Clone and build
echo "[3/7] Building pawd from source..."
cd /tmp
rm -rf paw
git clone -q --depth 1 https://github.com/poaiw-blockchain/paw.git
cd paw
make build > /dev/null 2>&1
sudo mv build/$BINARY /usr/local/bin/
cd ~
rm -rf /tmp/paw

# Verify binary
echo "[4/7] Verifying installation..."
$BINARY version

# Initialize node
echo "[5/7] Initializing node..."
MONIKER=${MONIKER:-"paw-node-$(hostname)"}
$BINARY init "$MONIKER" --chain-id $CHAIN_ID --home $HOME_DIR 2>/dev/null || true

# Download genesis
echo "[6/7] Downloading genesis..."
curl -sL $GENESIS_URL > $HOME_DIR/config/genesis.json

# Verify genesis
ACTUAL_SHA=$(sha256sum $HOME_DIR/config/genesis.json | awk '{print $1}')
if [[ "$ACTUAL_SHA" != "$GENESIS_SHA256" ]]; then
    echo "Warning: Genesis checksum mismatch!"
    echo "Expected: $GENESIS_SHA256"
    echo "Got: $ACTUAL_SHA"
fi

# Configure peers
sed -i "s/^seeds *=.*/seeds = \"$SEEDS\"/" $HOME_DIR/config/config.toml
sed -i "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME_DIR/config/config.toml

# Configure minimum gas price
sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0.001upaw"/' $HOME_DIR/config/app.toml

# Ask about state-sync
echo ""
read -p "Enable state-sync for fast sync? (recommended) [Y/n] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Configuring state-sync..."
    LATEST_HEIGHT=$(curl -s $RPC/block | jq -r .result.block.header.height)
    TRUST_HEIGHT=$((LATEST_HEIGHT - 2000))
    TRUST_HASH=$(curl -s "$RPC/block?height=$TRUST_HEIGHT" | jq -r .result.block_id.hash)

    sed -i "s/enable = false/enable = true/" $HOME_DIR/config/config.toml
    sed -i "s/trust_height = 0/trust_height = $TRUST_HEIGHT/" $HOME_DIR/config/config.toml
    sed -i "s/trust_hash = \"\"/trust_hash = \"$TRUST_HASH\"/" $HOME_DIR/config/config.toml
    sed -i "s|rpc_servers = \"\"|rpc_servers = \"$RPC,$RPC\"|" $HOME_DIR/config/config.toml
fi

# Create systemd service
echo "[7/7] Creating systemd service..."
sudo tee /etc/systemd/system/${BINARY}.service > /dev/null <<EOF
[Unit]
Description=PAW Node
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/local/bin/$BINARY start --home $HOME_DIR
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable $BINARY

echo ""
echo "================================"
echo "  Installation Complete!"
echo "================================"
echo ""
echo "Start node:    sudo systemctl start $BINARY"
echo "View logs:     journalctl -u $BINARY -f"
echo "Check status:  curl -s localhost:26657/status | jq '.result.sync_info'"
echo ""
echo "Get testnet tokens: https://testnet-faucet.poaiw.org"
echo ""
