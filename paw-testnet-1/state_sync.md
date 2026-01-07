# State Sync (paw-testnet-1)

Fast sync using state-sync (~5 minutes).

## Configuration

```bash
RPC="https://testnet-rpc.poaiw.org:443"
LATEST_HEIGHT=$(curl -s $RPC/block | jq -r .result.block.header.height)
TRUST_HEIGHT=$((LATEST_HEIGHT - 2000))
TRUST_HASH=$(curl -s "$RPC/block?height=$TRUST_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$RPC,$RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$TRUST_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" \
$HOME/.paw/config/config.toml

pawd tendermint unsafe-reset-all --home $HOME/.paw --keep-addr-book
pawd start
```

## RPC Endpoint

| Service | URL |
|---------|-----|
| RPC | https://testnet-rpc.poaiw.org |
