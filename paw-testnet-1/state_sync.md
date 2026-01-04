# PAW Testnet State Sync

State sync allows rapid bootstrapping of new nodes by fetching a snapshot from peers.

## Configuration

Add these settings to `~/.paw/config/config.toml`:

```toml
[statesync]
enable = true
rpc_servers = "https://testnet-rpc.poaiw.org:443,https://testnet-rpc.poaiw.org:443"
trust_height = TRUST_HEIGHT
trust_hash = "TRUST_HASH"
trust_period = "168h0m0s"
```

## Get Trust Height and Hash

Run this script to get current values:

```bash
#!/bin/bash
SNAP_RPC="https://testnet-rpc.poaiw.org:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
echo "trust_height = $BLOCK_HEIGHT"
echo "trust_hash = \"$TRUST_HASH\""
```

## Quick Setup

```bash
# Stop node
sudo systemctl stop pawd

# Reset data (keeps config)
pawd tendermint unsafe-reset-all --home ~/.paw --keep-addr-book

# Get trust values and update config
SNAP_RPC="https://testnet-rpc.poaiw.org:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height)
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000))
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true|" ~/.paw/config/config.toml
sed -i.bak -E "s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"|" ~/.paw/config/config.toml
sed -i.bak -E "s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT|" ~/.paw/config/config.toml
sed -i.bak -E "s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" ~/.paw/config/config.toml

# Start node
sudo systemctl start pawd
```

## Verification

Check sync progress:

```bash
curl -s localhost:26657/status | jq .result.sync_info
```
