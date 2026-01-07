# Snapshots (paw-testnet-1)

Chain data snapshots for faster sync (~30 minutes).

## Download Snapshot

```bash
# Stop node
sudo systemctl stop pawd

# Download and extract latest snapshot
cd $HOME/.paw
curl -sL https://testnet-rpc.poaiw.org/files/snapshots/latest.tar.lz4 | lz4 -dc | tar -xf -

# Start node
sudo systemctl start pawd
```

## Snapshot Info

- **Location**: https://testnet-rpc.poaiw.org/files/snapshots/
- **Format**: lz4 compressed tar archive
- **Update Frequency**: Every 12 hours
- **Contents**: `data/` directory (chain state and blocks)

## Manual Snapshot Download

```bash
# Check snapshot info
curl -s https://testnet-rpc.poaiw.org/files/snapshots/snapshot-info.json | jq .

# Download specific snapshot
wget https://testnet-rpc.poaiw.org/files/snapshots/latest.tar.lz4
```

## After Snapshot Restore

Verify your node is syncing:
```bash
curl -s localhost:26657/status | jq .result.sync_info
```
