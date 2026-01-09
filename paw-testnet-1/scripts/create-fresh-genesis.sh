#!/bin/bash
# Create fresh PAW testnet genesis with recorded mnemonics
# All mnemonics will be output to a file for SOPS encryption

set -e

CHAIN_ID="paw-testnet-1"
DENOM="upaw"
PAWD="$HOME/.paw/cosmovisor/genesis/bin/pawd"
WORK_DIR="/tmp/paw-genesis-$$"
OUTPUT_DIR="$WORK_DIR/output"

# Token amounts
VALIDATOR_STAKE="1000000000000${DENOM}"  # 1M PAW stake
VALIDATOR_BALANCE="2000000000000${DENOM}"  # 2M PAW total
FAUCET_BALANCE="100000000000000${DENOM}"  # 100M PAW for faucet

echo "=== Creating Fresh PAW Testnet Genesis ==="
echo "Chain ID: $CHAIN_ID"
echo "Working directory: $WORK_DIR"

mkdir -p "$WORK_DIR" "$OUTPUT_DIR"
cd "$WORK_DIR"

# Initialize temp chain home
TEMP_HOME="$WORK_DIR/home"
mkdir -p "$TEMP_HOME"

echo ""
echo "=== Initializing chain ==="
$PAWD init genesis-creator --chain-id "$CHAIN_ID" --home "$TEMP_HOME" 2>/dev/null

# Create mnemonics file
MNEMONICS_FILE="$OUTPUT_DIR/mnemonics.yaml"
cat > "$MNEMONICS_FILE" << 'EOF'
# PAW Testnet Account Mnemonics
# Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
# Chain ID: paw-testnet-1
# ENCRYPT WITH SOPS BEFORE COMMITTING

validators:
EOF

echo ""
echo "=== Creating validator accounts ==="

for i in 1 2 3 4; do
    echo "Creating validator $i..."

    # Generate new key and capture mnemonic
    MNEMONIC=$($PAWD keys add "val${i}" --keyring-backend test --home "$TEMP_HOME" --output json 2>&1 | grep -A1 '"mnemonic"' | tail -1 | tr -d '", ')

    # If that didn't work, try different approach
    if [ -z "$MNEMONIC" ] || [ "$MNEMONIC" = "mnemonic" ]; then
        # Delete and recreate to get mnemonic output
        $PAWD keys delete "val${i}" --keyring-backend test --home "$TEMP_HOME" -y 2>/dev/null || true
        OUTPUT=$($PAWD keys add "val${i}" --keyring-backend test --home "$TEMP_HOME" 2>&1)
        MNEMONIC=$(echo "$OUTPUT" | tail -1)
    fi

    # Get address
    ADDRESS=$($PAWD keys show "val${i}" --keyring-backend test --home "$TEMP_HOME" 2>/dev/null | grep 'address:' | awk '{print $2}')

    echo "  Address: $ADDRESS"

    # Add to mnemonics file
    cat >> "$MNEMONICS_FILE" << EOF
  val${i}:
    address: "$ADDRESS"
    mnemonic: "$MNEMONIC"
EOF

    # Add genesis account
    $PAWD add-genesis-account "$ADDRESS" "$VALIDATOR_BALANCE" --home "$TEMP_HOME"
done

echo ""
echo "=== Creating faucet account ==="

OUTPUT=$($PAWD keys add faucet --keyring-backend test --home "$TEMP_HOME" 2>&1)
FAUCET_MNEMONIC=$(echo "$OUTPUT" | tail -1)
FAUCET_ADDRESS=$($PAWD keys show faucet --keyring-backend test --home "$TEMP_HOME" 2>/dev/null | grep 'address:' | awk '{print $2}')

echo "  Address: $FAUCET_ADDRESS"

cat >> "$MNEMONICS_FILE" << EOF

faucet:
  address: "$FAUCET_ADDRESS"
  mnemonic: "$FAUCET_MNEMONIC"
EOF

$PAWD add-genesis-account "$FAUCET_ADDRESS" "$FAUCET_BALANCE" --home "$TEMP_HOME"

echo ""
echo "=== Creating test account ==="

OUTPUT=$($PAWD keys add testuser --keyring-backend test --home "$TEMP_HOME" 2>&1)
TEST_MNEMONIC=$(echo "$OUTPUT" | tail -1)
TEST_ADDRESS=$($PAWD keys show testuser --keyring-backend test --home "$TEMP_HOME" 2>/dev/null | grep 'address:' | awk '{print $2}')

echo "  Address: $TEST_ADDRESS"

cat >> "$MNEMONICS_FILE" << EOF

testuser:
  address: "$TEST_ADDRESS"
  mnemonic: "$TEST_MNEMONIC"
EOF

$PAWD add-genesis-account "$TEST_ADDRESS" "10000000000000${DENOM}" --home "$TEMP_HOME"

echo ""
echo "=== Generating genesis transactions ==="

# Create gentx for each validator
for i in 1 2 3 4; do
    echo "Creating gentx for validator $i..."

    # Create validator-specific home for gentx
    VAL_HOME="$WORK_DIR/val${i}"
    mkdir -p "$VAL_HOME/config"

    # Copy genesis
    cp "$TEMP_HOME/config/genesis.json" "$VAL_HOME/config/"

    # Copy keyring
    cp -r "$TEMP_HOME/keyring-test" "$VAL_HOME/"

    # Init to create priv_validator_key
    $PAWD init "val${i}" --chain-id "$CHAIN_ID" --home "$VAL_HOME" 2>/dev/null || true

    # Copy genesis again (init overwrites it)
    cp "$TEMP_HOME/config/genesis.json" "$VAL_HOME/config/"

    # Create gentx
    $PAWD gentx "val${i}" "$VALIDATOR_STAKE" \
        --chain-id "$CHAIN_ID" \
        --moniker "paw-validator-${i}" \
        --commission-rate 0.10 \
        --commission-max-rate 0.20 \
        --commission-max-change-rate 0.01 \
        --min-self-delegation 1 \
        --keyring-backend test \
        --home "$VAL_HOME" 2>/dev/null

    # Copy gentx to temp home
    cp "$VAL_HOME/config/gentx/"*.json "$TEMP_HOME/config/gentx/" 2>/dev/null || true

    # Save validator keys
    mkdir -p "$OUTPUT_DIR/validators/val${i}"
    cp "$VAL_HOME/config/priv_validator_key.json" "$OUTPUT_DIR/validators/val${i}/"
    cp "$VAL_HOME/config/node_key.json" "$OUTPUT_DIR/validators/val${i}/"
done

echo ""
echo "=== Collecting genesis transactions ==="
$PAWD collect-gentxs --home "$TEMP_HOME" 2>/dev/null

echo ""
echo "=== Validating genesis ==="
$PAWD validate-genesis --home "$TEMP_HOME"

# Copy final genesis
cp "$TEMP_HOME/config/genesis.json" "$OUTPUT_DIR/"

echo ""
echo "=== Output files ==="
echo "Genesis: $OUTPUT_DIR/genesis.json"
echo "Mnemonics: $OUTPUT_DIR/mnemonics.yaml"
echo "Validator keys: $OUTPUT_DIR/validators/"

echo ""
echo "=== Summary ==="
echo "Validators: val1, val2, val3, val4 (1M PAW staked each, 2M total)"
echo "Faucet: $FAUCET_ADDRESS (100M PAW)"
echo "Test user: $TEST_ADDRESS (10M PAW)"

echo ""
echo "Output directory: $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"
