# Snapshots (paw-testnet-1)

Chain data snapshots for faster sync (~30 minutes vs hours for genesis sync).

## Quick Download

```bash
# Stop your node
sudo systemctl stop pawd

# Backup validator state (IMPORTANT for validators!)
cp ~/.paw/data/priv_validator_state.json ~/.paw/priv_validator_state.json.backup

# Remove old data
cd ~/.paw
rm -rf data

# Download and extract latest snapshot
curl -L https://snapshots.poaiw.org/latest.tar.lz4 | lz4 -dc - | tar xf -

# Restore validator state (validators only)
cp ~/.paw/priv_validator_state.json.backup ~/.paw/data/priv_validator_state.json

# Start node
sudo systemctl start pawd
```

## Snapshot Info

| Property | Value |
|----------|-------|
| URL | https://snapshots.poaiw.org |
| Format | LZ4 compressed tar |
| Schedule | Every 6 hours |
| Retention | Last 3 snapshots |

## Latest Snapshot Metadata

```bash
# Get latest snapshot info (height, size, checksum)
curl -s https://snapshots.poaiw.org/latest.json | jq .
```

## Verify Checksum

```bash
# Download snapshot
curl -L -o snapshot.tar.lz4 https://snapshots.poaiw.org/latest.tar.lz4

# Get expected checksum
EXPECTED=$(curl -s https://snapshots.poaiw.org/latest.json | jq -r .sha256)

# Verify
echo "$EXPECTED  snapshot.tar.lz4" | sha256sum -c -
```

## Alternative: State Sync

For even faster sync (~5 minutes), use [state-sync](./state_sync.md).

## Resources

- **Snapshot Page**: https://snapshots.poaiw.org
- **Archive RPC**: https://testnet-archive.poaiw.org
- **State Sync Guide**: [state_sync.md](./state_sync.md)
