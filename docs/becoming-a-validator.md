# Becoming a Validator

## Prerequisites

1. **Running full node** - Fully synced with the network
2. **Testnet tokens** - Get from [faucet](https://testnet-faucet.poaiw.org)
3. **Hardware** - See [hardware requirements](./hardware-requirements.md)

## Step 1: Create Validator Key

```bash
# Create new key
pawd keys add validator --keyring-backend file

# Or recover existing key
pawd keys add validator --recover --keyring-backend file

# Save the mnemonic securely!
```

## Step 2: Get Testnet Tokens

Visit https://testnet-faucet.poaiw.org and request tokens to your validator address:

```bash
# Get your address
pawd keys show validator -a
```

## Step 3: Verify Sync Status

Ensure your node is fully synced before creating validator:

```bash
curl -s localhost:26657/status | jq '.result.sync_info.catching_up'
# Should return: false
```

## Step 4: Create Validator

```bash
pawd tx staking create-validator \
  --amount=1000000upaw \
  --pubkey=$(pawd tendermint show-validator) \
  --moniker="your-validator-name" \
  --chain-id=paw-mvp-1 \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --gas="auto" \
  --gas-adjustment=1.5 \
  --fees=5000upaw \
  --from=validator
```

## Step 5: Verify Validator

```bash
# Check validator status
pawd query staking validator $(pawd keys show validator --bech val -a)

# Check if signing blocks
pawd query slashing signing-info $(pawd tendermint show-validator)
```

## Validator Operations

### Edit Validator Info

```bash
pawd tx staking edit-validator \
  --moniker="new-name" \
  --website="https://your-website.com" \
  --details="Your validator description" \
  --chain-id=paw-mvp-1 \
  --from=validator
```

### Delegate More Tokens

```bash
pawd tx staking delegate $(pawd keys show validator --bech val -a) 1000000upaw \
  --from=validator \
  --chain-id=paw-mvp-1
```

### Unjail (if jailed)

```bash
pawd tx slashing unjail \
  --from=validator \
  --chain-id=paw-mvp-1 \
  --gas=auto \
  --fees=5000upaw
```

## Security Best Practices

1. **Use sentry nodes** - Never expose validator to public internet
2. **Backup keys** - Store `priv_validator_key.json` securely offline
3. **Enable firewall** - Only allow P2P port (26656) from sentries
4. **Monitor uptime** - Set up alerting for missed blocks
5. **Use tmkms** - Hardware security module for signing

## Key Files to Backup

```bash
# Critical files
~/.paw/config/priv_validator_key.json  # Validator signing key
~/.paw/config/node_key.json            # Node identity key
~/.paw/data/priv_validator_state.json  # Signing state

# Never share these files!
```

## Monitoring

Set up Prometheus metrics:

```bash
# Enable in config.toml
prometheus = true
prometheus_listen_addr = ":26660"
```

Access metrics at: `http://localhost:26660/metrics`

## Resources

- [Validator Hardware Guide](https://github.com/poaiw-blockchain/paw/blob/main/docs/VALIDATOR_HARDWARE_REQUIREMENTS.md)
- [Key Management](https://github.com/poaiw-blockchain/paw/blob/main/docs/VALIDATOR_KEY_MANAGEMENT.md)
- [Sentry Architecture](https://github.com/poaiw-blockchain/paw/blob/main/docs/SENTRY_ARCHITECTURE.md)
