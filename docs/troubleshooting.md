# Troubleshooting Guide

## Common Issues

### Node Won't Start

**Symptom:** Node fails to start with panic or error

**Solutions:**
```bash
# Check binary version
pawd version

# Verify genesis hash
sha256sum ~/.paw/config/genesis.json
# Expected: b149e5aa1869973bdcedcb808c340e97d3b0c951cb1243db901d84d3b3f659b5

# Check for port conflicts
sudo lsof -i :26656
sudo lsof -i :26657

# Reset state (last resort)
pawd tendermint unsafe-reset-all --home ~/.paw --keep-addr-book
```

### Sync Issues

**Symptom:** Node stuck syncing or falling behind

**Check sync status:**
```bash
curl -s localhost:26657/status | jq '.result.sync_info'
```

**Solutions:**
1. Add more peers:
```bash
PEERS=$(curl -s https://artifacts.poaiw.org/paw-testnet-1/peers.txt)
sed -i "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.paw/config/config.toml
sudo systemctl restart pawd
```

2. Use state-sync (fastest):
```bash
# See state-sync guide
```

3. Download snapshot:
```bash
# See snapshot guide
```

### Peer Discovery Failed

**Symptom:** 0 peers connected

**Check peers:**
```bash
curl -s localhost:26657/net_info | jq '.result.n_peers'
```

**Solutions:**
```bash
# Verify seeds are configured
grep "^seeds" ~/.paw/config/config.toml

# Download fresh address book
curl -sL https://artifacts.poaiw.org/paw-testnet-1/addrbook.json > ~/.paw/config/addrbook.json
sudo systemctl restart pawd

# Check firewall
sudo ufw status
sudo ufw allow 26656/tcp
```

### State-Sync Errors

**Symptom:** State-sync fails to find snapshots

**Solutions:**
```bash
# Update trust height/hash
RPC="https://testnet-rpc.poaiw.org:443"
LATEST=$(curl -s $RPC/block | jq -r .result.block.header.height)
TRUST_HEIGHT=$((LATEST - 2000))
TRUST_HASH=$(curl -s "$RPC/block?height=$TRUST_HEIGHT" | jq -r .result.block_id.hash)

echo "Trust Height: $TRUST_HEIGHT"
echo "Trust Hash: $TRUST_HASH"

# Update config.toml with new values
```

### Disk Space Issues

**Symptom:** Node crashes with "no space left"

**Check usage:**
```bash
df -h ~/.paw
du -sh ~/.paw/data
```

**Solutions:**
```bash
# Enable pruning
sed -i 's/pruning = "nothing"/pruning = "default"/' ~/.paw/config/app.toml

# Compact database (while stopped)
pawd tendermint compact-wal-file --home ~/.paw
```

### Memory Errors (OOM)

**Symptom:** Node killed by OOM killer

**Check memory:**
```bash
free -h
journalctl -u pawd | grep -i "killed"
```

**Solutions:**
```bash
# Add swap space
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Reduce mempool size
sed -i 's/size = 5000/size = 1000/' ~/.paw/config/config.toml
```

### Validator Jail

**Symptom:** Validator jailed for downtime

**Check jail status:**
```bash
pawd query staking validator $(pawd keys show validator --bech val -a)
```

**Unjail:**
```bash
pawd tx slashing unjail \
  --from validator \
  --chain-id paw-testnet-1 \
  --gas auto \
  --gas-adjustment 1.5 \
  --fees 5000upaw
```

## Useful Debug Commands

```bash
# View logs
journalctl -u pawd -f

# Check node ID
pawd tendermint show-node-id

# Check validator key
pawd tendermint show-validator

# Query latest block
curl -s localhost:26657/block | jq '.result.block.header.height'

# Check consensus state
curl -s localhost:26657/consensus_state | jq '.result.round_state.height_vote_set[0]'
```

## Getting Help

- Discord: https://discord.gg/poaiw
- GitHub Issues: https://github.com/poaiw-blockchain/paw/issues
- Telegram: https://t.me/poaiw
