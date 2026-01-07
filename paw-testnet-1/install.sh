#!/bin/bash
set -e

# PAW Testnet-1 One-Line Installer
# Usage: curl -sL https://raw.githubusercontent.com/poaiw-blockchain/testnets/main/paw-testnet-1/install.sh | bash

CHAIN_ID="paw-testnet-1"
BINARY="pawd"
HOME_DIR="$HOME/.paw"
GITHUB_RAW="https://raw.githubusercontent.com/poaiw-blockchain/testnets/main/paw-testnet-1"
RPC="https://testnet-rpc.poaiw.org:443"
SEEDS="f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656"
PEERS="f1499c319fed373f0625902009778c38dd89ff4a@54.39.103.49:11656,4d4ab236a6ab88eafe5a3745cc3a00c39cfe227a@54.39.103.49:11756,6dd222b005b7fa30d805d694cc1cd98276d7a976@139.99.149.160:11856,97801086479686da8ba49a8e3e0d1d4e4179abf1@139.99.149.160:11956"

echo "=========================================="
echo "  PAW Testnet-1 Node Installer"
echo "=========================================="
echo ""

# Check dependencies
if ! command -v jq &> /dev/null; then
    echo "Installing jq..."
    sudo apt-get update && sudo apt-get install -y jq lz4
fi

# Download binary
echo "Downloading $BINARY..."
RELEASE_URL="https://github.com/poaiw-blockchain/paw/releases/latest/download/${BINARY}_linux_amd64"
if curl -sLo /tmp/$BINARY "$RELEASE_URL" 2>/dev/null; then
    sudo mv /tmp/$BINARY /usr/local/bin/
    sudo chmod +x /usr/local/bin/$BINARY
else
    echo "Binary not found at release URL. Building from source..."
    if ! command -v go &> /dev/null; then
        echo "Go not installed. Please install Go 1.21+ and retry."
        exit 1
    fi
    git clone https://github.com/poaiw-blockchain/paw.git /tmp/paw
    cd /tmp/paw && make install
    cd - > /dev/null
fi

# Initialize node
echo "Initializing node..."
MONIKER=${1:-"my-paw-node"}
$BINARY init "$MONIKER" --chain-id $CHAIN_ID --home $HOME_DIR 2>/dev/null || true

# Download genesis from GitHub (community standard)
echo "Downloading genesis.json from GitHub..."
curl -sL "$GITHUB_RAW/genesis.json" > $HOME_DIR/config/genesis.json

# Configure peers
echo "Configuring peers..."
sed -i "s/^seeds *=.*/seeds = \"$SEEDS\"/" $HOME_DIR/config/config.toml
sed -i "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME_DIR/config/config.toml

# Optional: Enable state-sync for fast sync
echo ""
read -p "Enable state-sync for fast sync? (Y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Configuring state-sync..."
    LATEST_HEIGHT=$(curl -s $RPC/block | jq -r .result.block.header.height)
    TRUST_HEIGHT=$((LATEST_HEIGHT - 2000))
    TRUST_HASH=$(curl -s "$RPC/block?height=$TRUST_HEIGHT" | jq -r .result.block_id.hash)

    sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
    s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$RPC,$RPC\"| ; \
    s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$TRUST_HEIGHT| ; \
    s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" \
    $HOME_DIR/config/config.toml

    echo "State-sync configured (trust height: $TRUST_HEIGHT)"
fi

# Create systemd service
echo "Creating systemd service..."
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

# Start node
echo ""
read -p "Start node now? (Y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    sudo systemctl start $BINARY
    echo ""
    echo "=========================================="
    echo "  Node started successfully!"
    echo "=========================================="
    echo ""
    echo "View logs:     sudo journalctl -u $BINARY -f"
    echo "Check status:  $BINARY status | jq .SyncInfo"
    echo "Get tokens:    https://testnet-faucet.poaiw.org"
    echo ""
else
    echo ""
    echo "Node configured but not started."
    echo "Start with: sudo systemctl start $BINARY"
fi
