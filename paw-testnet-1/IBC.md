# PAW Testnet IBC Documentation

This document describes the Inter-Blockchain Communication (IBC) connections for the PAW testnet.

## Active IBC Connections

### PAW <-> AURA Testnet

| Property | PAW Testnet | AURA Testnet |
|----------|-------------|--------------|
| Chain ID | `paw-testnet-1` | `aura-testnet-1` |
| Connection ID | `connection-0` | `connection-0` |
| Client ID | `07-tendermint-0` | `07-tendermint-0` |
| Transfer Channel | `channel-0` | `channel-0` |
| Port | `transfer` | `transfer` |

## IBC Metadata

```json
{
  "$schema": "../_IBC/ibc.schema.json",
  "chain_1": {
    "chain_name": "pawtestnet",
    "client_id": "07-tendermint-0",
    "connection_id": "connection-0"
  },
  "chain_2": {
    "chain_name": "auratestnet",
    "client_id": "07-tendermint-0",
    "connection_id": "connection-0"
  },
  "channels": [
    {
      "chain_1": {
        "channel_id": "channel-0",
        "port_id": "transfer"
      },
      "chain_2": {
        "channel_id": "channel-0",
        "port_id": "transfer"
      },
      "ordering": "unordered",
      "version": "ics20-1",
      "tags": {
        "status": "live",
        "preferred": true
      }
    }
  ]
}
```

## IBC Token Transfers

### Send PAW to AURA Testnet

```bash
pawd tx ibc-transfer transfer \
  transfer \
  channel-0 \
  aura1<recipient-address> \
  1000000upaw \
  --from <your-wallet> \
  --chain-id paw-testnet-1 \
  --gas auto \
  --gas-adjustment 1.3 \
  --fees 5000upaw
```

### Receive AURA on PAW Testnet

When AURA tokens are received on PAW testnet, they appear with the IBC denom:

```
ibc/<hash>
```

To find the IBC denom hash:
```bash
pawd q ibc-transfer denom-hash transfer/channel-0/uaura
```

## Relayer Configuration

### Hermes Relayer Config

```toml
[[chains]]
id = 'paw-testnet-1'
rpc_addr = 'https://testnet-rpc.poaiw.org'
grpc_addr = 'https://testnet-grpc.poaiw.org'
websocket_addr = 'wss://testnet-ws.poaiw.org/websocket'
account_prefix = 'paw'
key_name = 'paw-relayer'
store_prefix = 'ibc'
gas_price = { price = 0.001, denom = 'upaw' }
max_gas = 3000000
clock_drift = '5s'
trusting_period = '14days'

[[chains]]
id = 'aura-testnet-1'
rpc_addr = 'https://testnet-rpc.aurablockchain.org'
grpc_addr = 'https://testnet-grpc.aurablockchain.org'
websocket_addr = 'wss://testnet-ws.aurablockchain.org/websocket'
account_prefix = 'aura'
key_name = 'aura-relayer'
store_prefix = 'ibc'
gas_price = { price = 0.001, denom = 'uaura' }
max_gas = 3000000
clock_drift = '5s'
trusting_period = '14days'
```

### Go Relayer (rly) Config

```yaml
chains:
  paw-testnet-1:
    type: cosmos
    value:
      key: paw-relayer
      chain-id: paw-testnet-1
      rpc-addr: https://testnet-rpc.poaiw.org
      account-prefix: paw
      keyring-backend: test
      gas-adjustment: 1.3
      gas-prices: 0.001upaw
      debug: false
      timeout: 30s
      output-format: json
      sign-mode: direct

  aura-testnet-1:
    type: cosmos
    value:
      key: aura-relayer
      chain-id: aura-testnet-1
      rpc-addr: https://testnet-rpc.aurablockchain.org
      account-prefix: aura
      keyring-backend: test
      gas-adjustment: 1.3
      gas-prices: 0.001uaura
      debug: false
      timeout: 30s
      output-format: json
      sign-mode: direct

paths:
  paw-aura:
    src:
      chain-id: paw-testnet-1
      client-id: 07-tendermint-0
      connection-id: connection-0
    dst:
      chain-id: aura-testnet-1
      client-id: 07-tendermint-0
      connection-id: connection-0
```

## Monitoring IBC Channels

### Check Channel Status

```bash
# PAW side
pawd q ibc channel channels

# Check specific channel
pawd q ibc channel end transfer channel-0
```

### Check Pending Packets

```bash
# Unreceived packets
pawd q ibc channel unreceived-packets transfer channel-0

# Unreceived acks
pawd q ibc channel unreceived-acks transfer channel-0
```

## Troubleshooting

### Common Issues

1. **Packet Timeout**: If transfers are timing out, check:
   - Relayer is running and synced
   - Both chains are producing blocks
   - Channel is in OPEN state

2. **Insufficient Fees**: IBC transfers require gas on both chains:
   - Sender pays for the send transaction
   - Relayer pays for receive/acknowledgement

3. **Wrong Channel**: Always verify you're using the correct channel for the destination chain:
   ```bash
   pawd q ibc channel channels --output json | jq '.channels[] | {channel_id, counterparty}'
   ```

## Support

For IBC-related issues:
- GitHub: https://github.com/poaiw-blockchain/testnets/issues
- Discord: https://discord.gg/paw
