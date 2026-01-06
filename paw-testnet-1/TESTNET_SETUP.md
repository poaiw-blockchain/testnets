# PAW Testnet Setup Checklist

**Chain ID**: `paw-testnet-1`
**Validators**: 4 (staged deployment)
**Port Range**: 11000-11999

## Server Allocation

| Validator | Server | VPN IP | Ports |
|-----------|--------|--------|-------|
| val1 | paw-testnet | 10.10.0.2 | RPC:11657, P2P:11656, gRPC:11090, REST:11317 |
| val2 | paw-testnet | 10.10.0.2 | RPC:11757, P2P:11756, gRPC:11190, REST:11417 |
| val3 | services-testnet | 10.10.0.4 | RPC:11857, P2P:11856, gRPC:11290, REST:11517 |
| val4 | services-testnet | 10.10.0.4 | RPC:11957, P2P:11956, gRPC:11390, REST:11617 |

## Phase 1: Genesis Creation (Local)

```bash
# On bcpc (local machine)
cd ~/blockchain-projects/paw

# Build binary
make build

# Initialize 4 validator keys
for i in 1 2 3 4; do
  ./build/pawd init val${i} --chain-id paw-testnet-1 --home ~/.paw-val${i}
  ./build/pawd keys add val${i} --keyring-backend test --home ~/.paw-val${i}
done

# Collect gentxs and create genesis
# Add all 4 validators to genesis with equal stake (25% each)
./build/pawd genesis add-genesis-account val1 1000000000000upaw --keyring-backend test --home ~/.paw-val1
./build/pawd genesis add-genesis-account val2 1000000000000upaw --keyring-backend test --home ~/.paw-val2
./build/pawd genesis add-genesis-account val3 1000000000000upaw --keyring-backend test --home ~/.paw-val3
./build/pawd genesis add-genesis-account val4 1000000000000upaw --keyring-backend test --home ~/.paw-val4

# Create gentxs (250B upaw each = 25% voting power)
./build/pawd genesis gentx val1 250000000000upaw --chain-id paw-testnet-1 --keyring-backend test --home ~/.paw-val1
./build/pawd genesis gentx val2 250000000000upaw --chain-id paw-testnet-1 --keyring-backend test --home ~/.paw-val2
./build/pawd genesis gentx val3 250000000000upaw --chain-id paw-testnet-1 --keyring-backend test --home ~/.paw-val3
./build/pawd genesis gentx val4 250000000000upaw --chain-id paw-testnet-1 --keyring-backend test --home ~/.paw-val4

# Collect all gentxs into final genesis
./build/pawd genesis collect-gentxs --home ~/.paw-val1
```

## Phase 2: Deploy Validators 1 & 2 (paw-testnet)

### 2.1 Copy Files to Server
```bash
# Copy binary and configs
scp build/pawd paw-testnet:~/.paw/cosmovisor/genesis/bin/
scp ~/.paw-val1/config/genesis.json paw-testnet:~/.paw-val1/config/
scp ~/.paw-val1/config/priv_validator_key.json paw-testnet:~/.paw-val1/config/
scp ~/.paw-val2/config/priv_validator_key.json paw-testnet:~/.paw-val2/config/
```

### 2.2 Configure Validator 1 (paw-testnet)
```bash
ssh paw-testnet

# config.toml
sed -i 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/0.0.0.0:11657"/' ~/.paw-val1/config/config.toml
sed -i 's/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:11656"/' ~/.paw-val1/config/config.toml
sed -i 's/prometheus_listen_addr = ":26660"/prometheus_listen_addr = ":11660"/' ~/.paw-val1/config/config.toml

# app.toml
sed -i 's/address = "tcp:\/\/localhost:1317"/address = "tcp:\/\/0.0.0.0:11317"/' ~/.paw-val1/config/app.toml
sed -i 's/address = "localhost:9090"/address = "0.0.0.0:11090"/' ~/.paw-val1/config/app.toml
```

### 2.3 Configure Validator 2 (paw-testnet)
```bash
# config.toml
sed -i 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/0.0.0.0:11757"/' ~/.paw-val2/config/config.toml
sed -i 's/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:11756"/' ~/.paw-val2/config/config.toml
sed -i 's/prometheus_listen_addr = ":26660"/prometheus_listen_addr = ":11760"/' ~/.paw-val2/config/config.toml

# app.toml
sed -i 's/address = "tcp:\/\/localhost:1317"/address = "tcp:\/\/0.0.0.0:11417"/' ~/.paw-val2/config/app.toml
sed -i 's/address = "localhost:9090"/address = "0.0.0.0:11190"/' ~/.paw-val2/config/app.toml
```

### 2.4 Get Node IDs and Configure Peers
```bash
VAL1_ID=$(~/.paw/cosmovisor/genesis/bin/pawd tendermint show-node-id --home ~/.paw-val1)
VAL2_ID=$(~/.paw/cosmovisor/genesis/bin/pawd tendermint show-node-id --home ~/.paw-val2)

# Set persistent_peers for val1
sed -i "s/persistent_peers = \"\"/persistent_peers = \"${VAL2_ID}@127.0.0.1:11756\"/" ~/.paw-val1/config/config.toml

# Set persistent_peers for val2
sed -i "s/persistent_peers = \"\"/persistent_peers = \"${VAL1_ID}@127.0.0.1:11656\"/" ~/.paw-val2/config/config.toml
```

### 2.5 Start Validators 1 & 2
```bash
# Start val1
nohup ~/.paw/cosmovisor/genesis/bin/pawd start --home ~/.paw-val1 > ~/.paw-val1/node.log 2>&1 &

# Wait 10 seconds
sleep 10

# Start val2
nohup ~/.paw/cosmovisor/genesis/bin/pawd start --home ~/.paw-val2 > ~/.paw-val2/node.log 2>&1 &
```

### 2.6 CHECKPOINT: Verify 2-Validator Consensus
```bash
# Wait for blocks to produce
sleep 30

# Check block height advancing
curl -s http://127.0.0.1:11657/status | jq '.result.sync_info.latest_block_height'
curl -s http://127.0.0.1:11757/status | jq '.result.sync_info.latest_block_height'

# Verify both validators signing (should show 2 validators)
curl -s http://127.0.0.1:11657/validators | jq '.result.validators | length'

# Check consensus state - should show 50% voting power online
curl -s http://127.0.0.1:11657/consensus_state | jq '.result.round_state.votes'

# MUST SEE: Blocks advancing, 2 validators active, both signing
# If not working, DO NOT proceed to Phase 3
```

## Phase 3: Add Validator 3 (services-testnet)

### 3.1 Copy Files to Server
```bash
# From bcpc
scp build/pawd services-testnet:~/.paw/cosmovisor/genesis/bin/
scp ~/.paw-val1/config/genesis.json services-testnet:~/.paw-val3/config/
scp ~/.paw-val3/config/priv_validator_key.json services-testnet:~/.paw-val3/config/
```

### 3.2 Configure Validator 3 (services-testnet)
```bash
ssh services-testnet

# config.toml
sed -i 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/0.0.0.0:11857"/' ~/.paw-val3/config/config.toml
sed -i 's/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:11856"/' ~/.paw-val3/config/config.toml
sed -i 's/prometheus_listen_addr = ":26660"/prometheus_listen_addr = ":11860"/' ~/.paw-val3/config/config.toml

# app.toml
sed -i 's/address = "tcp:\/\/localhost:1317"/address = "tcp:\/\/0.0.0.0:11517"/' ~/.paw-val3/config/app.toml
sed -i 's/address = "localhost:9090"/address = "0.0.0.0:11290"/' ~/.paw-val3/config/app.toml

# Get node ID
VAL3_ID=$(~/.paw/cosmovisor/genesis/bin/pawd tendermint show-node-id --home ~/.paw-val3)

# Set persistent_peers (connect to val1 and val2 on paw-testnet via VPN)
sed -i "s/persistent_peers = \"\"/persistent_peers = \"${VAL1_ID}@10.10.0.2:11656,${VAL2_ID}@10.10.0.2:11756\"/" ~/.paw-val3/config/config.toml
```

### 3.3 Update Validators 1 & 2 with Val3 Peer
```bash
# On paw-testnet, add val3 to persistent_peers
ssh paw-testnet
sed -i "s/persistent_peers = \".*\"/persistent_peers = \"${VAL2_ID}@127.0.0.1:11756,${VAL3_ID}@10.10.0.4:11856\"/" ~/.paw-val1/config/config.toml
sed -i "s/persistent_peers = \".*\"/persistent_peers = \"${VAL1_ID}@127.0.0.1:11656,${VAL3_ID}@10.10.0.4:11856\"/" ~/.paw-val2/config/config.toml
```

### 3.4 Start Validator 3
```bash
ssh services-testnet
nohup ~/.paw/cosmovisor/genesis/bin/pawd start --home ~/.paw-val3 > ~/.paw-val3/node.log 2>&1 &
```

### 3.5 CHECKPOINT: Verify 3-Validator Consensus
```bash
# Wait for sync
sleep 60

# Check all 3 validators
curl -s http://10.10.0.2:11657/validators | jq '.result.validators | length'
# Should return: 3

# Check val3 is synced
curl -s http://10.10.0.4:11857/status | jq '.result.sync_info'

# Verify 75% voting power (3 of 4 validators = enough for consensus)
curl -s http://10.10.0.2:11657/consensus_state | jq '.result.round_state'

# MUST SEE: 3 validators active, blocks advancing, val3 synced
# If not working, DO NOT proceed to Phase 4
```

## Phase 4: Add Validator 4 (services-testnet)

### 4.1 Copy Files
```bash
scp ~/.paw-val4/config/priv_validator_key.json services-testnet:~/.paw-val4/config/
scp ~/.paw-val1/config/genesis.json services-testnet:~/.paw-val4/config/
```

### 4.2 Configure Validator 4
```bash
ssh services-testnet

# config.toml
sed -i 's/laddr = "tcp:\/\/127.0.0.1:26657"/laddr = "tcp:\/\/0.0.0.0:11957"/' ~/.paw-val4/config/config.toml
sed -i 's/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:11956"/' ~/.paw-val4/config/config.toml
sed -i 's/prometheus_listen_addr = ":26660"/prometheus_listen_addr = ":11960"/' ~/.paw-val4/config/config.toml

# app.toml
sed -i 's/address = "tcp:\/\/localhost:1317"/address = "tcp:\/\/0.0.0.0:11617"/' ~/.paw-val4/config/app.toml
sed -i 's/address = "localhost:9090"/address = "0.0.0.0:11390"/' ~/.paw-val4/config/app.toml

# Get node ID
VAL4_ID=$(~/.paw/cosmovisor/genesis/bin/pawd tendermint show-node-id --home ~/.paw-val4)

# Set persistent_peers
sed -i "s/persistent_peers = \"\"/persistent_peers = \"${VAL1_ID}@10.10.0.2:11656,${VAL3_ID}@127.0.0.1:11856\"/" ~/.paw-val4/config/config.toml
```

### 4.3 Update All Validators with Val4 Peer
```bash
# Update val1, val2 on paw-testnet
ssh paw-testnet
# Add val4 to their peer lists

# Update val3 on services-testnet
ssh services-testnet
sed -i "s/persistent_peers = \".*\"/persistent_peers = \"${VAL1_ID}@10.10.0.2:11656,${VAL4_ID}@127.0.0.1:11956\"/" ~/.paw-val3/config/config.toml
```

### 4.4 Start Validator 4
```bash
nohup ~/.paw/cosmovisor/genesis/bin/pawd start --home ~/.paw-val4 > ~/.paw-val4/node.log 2>&1 &
```

### 4.5 FINAL CHECKPOINT: Verify 4-Validator Consensus
```bash
# Wait for sync
sleep 60

# Check all 4 validators active
curl -s http://10.10.0.2:11657/validators | jq '.result.validators | length'
# Should return: 4

# Check consensus participation
curl -s http://10.10.0.2:11657/consensus_state | jq '.result.round_state.votes[0].prevotes_bit_array'
# Should show all 4 validators voting

# Verify blocks advancing
for port in 11657 11757 11857 11957; do
  echo "Port $port: $(curl -s http://10.10.0.2:$port/status 2>/dev/null | jq -r '.result.sync_info.latest_block_height' || curl -s http://10.10.0.4:$port/status | jq -r '.result.sync_info.latest_block_height')"
done

# Target: 95%+ consensus (all 4 validators signing most blocks)
```

## Phase 5: Deploy Supporting Services

After 4-validator consensus is stable:

```bash
# On paw-testnet (primary services)
# Explorer: 11080, Faucet: 11081, WS: 11082

# On services-testnet (backup/indexer)
# Indexer: 11101, WS Proxy: 11201
```

## Health Check Commands

```bash
# Quick status
curl -s http://10.10.0.2:11657/status | jq '{height: .result.sync_info.latest_block_height, catching_up: .result.sync_info.catching_up}'

# Validator set
curl -s http://10.10.0.2:11657/validators | jq '.result.validators[] | {address: .address, voting_power: .voting_power}'

# Peer count
curl -s http://10.10.0.2:11657/net_info | jq '.result.n_peers'
```

## Rollback Procedure

If consensus fails at any phase:
1. Stop all validators: `pkill -f pawd`
2. Check logs: `tail -100 ~/.paw-valX/node.log`
3. Reset state if needed: `pawd tendermint unsafe-reset-all --home ~/.paw-valX`
4. Restart from last working phase
