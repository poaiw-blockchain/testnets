# State Sync (paw-testnet-1)

Fast sync using state-sync (completes in ~5 minutes).

## Prerequisites

- `pawd` binary installed
- Node initialized with `pawd init <moniker> --chain-id paw-testnet-1`
- genesis.json downloaded

## State Sync Configuration

```bash
# Variables
RPC="https://testnet-rpc.poaiw.org:443"

# Get trust height and hash
LATEST_HEIGHT=$(curl -s $RPC/block | jq -r .result.block.header.height)
TRUST_HEIGHT=$((LATEST_HEIGHT - 2000))
TRUST_HASH=$(curl -s "$RPC/block?height=$TRUST_HEIGHT" | jq -r .result.block_id.hash)

echo "Trust Height: $TRUST_HEIGHT"
echo "Trust Hash: $TRUST_HASH"

# Update config.toml
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$RPC,$RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$TRUST_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" \
$HOME/.paw/config/config.toml
```

## Start Node

```bash
# Reset data (required for state-sync)
pawd tendermint unsafe-reset-all --home $HOME/.paw --keep-addr-book

# Start node
pawd start
```

## Verify Sync

```bash
# Check sync status (catching_up should become false)
curl -s localhost:26657/status | jq .result.sync_info
```

## RPC Endpoints

| Endpoint | URL |
|----------|-----|
| Primary RPC | https://testnet-rpc.poaiw.org |
