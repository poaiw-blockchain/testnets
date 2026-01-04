# PAW Testnet Snapshots

This document describes how to use snapshots for fast node synchronization.

## Available Snapshots

| Type | Size | Update Frequency | Pruning | Download |
|------|------|------------------|---------|----------|
| Pruned | ~5 GB | Daily | default | [Download](https://artifacts.poaiw.org/snapshots/paw-testnet-1-pruned-latest.tar.lz4) |
| Archive | ~20 GB | Weekly | nothing | [Download](https://artifacts.poaiw.org/snapshots/paw-testnet-1-archive-latest.tar.lz4) |

## Quick Restore

### Using Pruned Snapshot (Recommended)

```bash
# 1. Stop the node
sudo systemctl stop pawd

# 2. Backup priv_validator_state.json
cp ~/.paw/data/priv_validator_state.json ~/.paw/priv_validator_state.json.backup

# 3. Remove old data
rm -rf ~/.paw/data

# 4. Download and extract snapshot
curl -L https://artifacts.poaiw.org/snapshots/paw-testnet-1-pruned-latest.tar.lz4 | lz4 -dc - | tar -xf - -C ~/.paw

# 5. Restore priv_validator_state.json
cp ~/.paw/priv_validator_state.json.backup ~/.paw/data/priv_validator_state.json

# 6. Start the node
sudo systemctl start pawd
```

### Using Archive Snapshot

```bash
# 1. Stop the node
sudo systemctl stop pawd

# 2. Backup priv_validator_state.json
cp ~/.paw/data/priv_validator_state.json ~/.paw/priv_validator_state.json.backup

# 3. Remove old data
rm -rf ~/.paw/data

# 4. Download and extract snapshot
curl -L https://artifacts.poaiw.org/snapshots/paw-testnet-1-archive-latest.tar.lz4 | lz4 -dc - | tar -xf - -C ~/.paw

# 5. Restore priv_validator_state.json
cp ~/.paw/priv_validator_state.json.backup ~/.paw/data/priv_validator_state.json

# 6. Start the node
sudo systemctl start pawd
```

## Snapshot Verification

Each snapshot comes with a checksum file:

```bash
# Download checksum
curl -O https://artifacts.poaiw.org/snapshots/paw-testnet-1-pruned-latest.sha256

# Verify (after downloading the snapshot)
sha256sum -c paw-testnet-1-pruned-latest.sha256
```

## Snapshot Contents

The snapshot archive contains:

```
data/
├── application.db/    # Application state
├── blockstore.db/     # Block storage
├── cs.wal/            # Consensus WAL
├── evidence.db/       # Evidence database
├── snapshots/         # State sync snapshots
├── state.db/          # State database
└── tx_index.db/       # Transaction index
```

## When to Use Snapshots

**Use Pruned Snapshot When:**
- Setting up a new full node
- Node fell too far behind to sync normally
- Quick recovery after data corruption
- Testing purposes

**Use Archive Snapshot When:**
- Running an archive/indexer node
- Need full historical data
- Running block explorers
- Historical queries required

## Alternative: State Sync

For even faster sync without downloading large files, use [State Sync](./state_sync.md).

## Snapshot Schedule

| Snapshot Type | Generation Time (UTC) |
|---------------|----------------------|
| Pruned (daily) | 00:00 |
| Archive (weekly) | Sunday 00:00 |

## Troubleshooting

### "Wrong Block.Header.AppHash" Error

This usually means the snapshot is incompatible with your binary version:
1. Ensure you're using the correct binary version
2. Try a newer snapshot
3. Use state sync instead

### Slow Extraction

For faster extraction, ensure you have `lz4` installed:
```bash
# Ubuntu/Debian
sudo apt install lz4

# macOS
brew install lz4
```

### Disk Space Issues

Before restoring, ensure you have enough disk space:
- Pruned: At least 15 GB free
- Archive: At least 50 GB free

## Support

For snapshot-related issues:
- GitHub: https://github.com/poaiw-blockchain/testnets/issues
- Discord: https://discord.gg/paw
