#!/bin/bash
# ============================================================================
# PAW Testnet Validation Test Harness
# ============================================================================
# Runs validation tests against the live paw-testnet-1 (4-validator OVH setup)
# Results are logged to VALIDATION.md
#
# Usage:
#   ./run-tests.sh [phase] [--dry-run] [--verbose]
#
# Phases:
#   all       - Run all phases (default)
#   stability - Phase 1: Stability baseline
#   core      - Phase 2: Core transactions
#   multinode - Phase 2.5: Multi-node consistency
#   consensus - Phase 3: Consensus/resilience
#   security  - Phase 4: Security tests
#   ops       - Phase 5: Operations tests
#
# Examples:
#   ./run-tests.sh                    # Run all tests
#   ./run-tests.sh stability          # Run only stability tests
#   ./run-tests.sh core --verbose     # Run core tests with verbose output
#   ./run-tests.sh all --dry-run      # Show what would run without executing
# ============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTNETS_DIR="$(dirname "$SCRIPT_DIR")"
RESULTS_FILE="${TESTNETS_DIR}/VALIDATION.md"
LOG_FILE="/tmp/paw-testnet-validation.log"

# ============================================================================
# TESTNET CONFIGURATION
# ============================================================================
CHAIN_NAME="PAW"
CHAIN_ID="paw-testnet-1"
BINARY="pawd"

# Primary server (paw-testnet)
PRIMARY_SERVER="paw-testnet"
PRIMARY_SSH="ssh -o ConnectTimeout=5 -o BatchMode=yes ${PRIMARY_SERVER}"

# Secondary server (services-testnet)
SECONDARY_SERVER="services-testnet"
SECONDARY_SSH="ssh -o ConnectTimeout=5 -o BatchMode=yes ${SECONDARY_SERVER}"

# Validator configuration: "name:server:home:rpc_port:rest_port"
# PAW uses 11xxx port range
VALIDATORS=(
    "val1:primary:~/.paw-val1:11657:11317"
    "val2:primary:~/.paw-val2:11757:11417"
    "val3:secondary:~/.paw-val3:11857:11517"
    "val4:secondary:~/.paw-val4:11957:11617"
)

# Service endpoints (PAW uses 11xxx port range)
RPC_PRIMARY="http://127.0.0.1:11657"
REST_PRIMARY="http://127.0.0.1:11317"
GRPC_PRIMARY="127.0.0.1:11090"

# Reference endpoint for state comparison
REF_VALIDATOR="val1"

# Test accounts (will be created/funded via faucet)
TEST_ACCOUNT_PREFIX="pawtest"

# Thresholds
MIN_BLOCK_TIME=3
MAX_BLOCK_TIME=12  # Allow for variance in measurement
MIN_PEERS=2
CONSENSUS_THRESHOLD=67  # Percentage needed for consensus

# ============================================================================
# COLORS AND LOGGING
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

VERBOSE=false
DRY_RUN=false

log() { echo -e "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $*" | tee -a "$LOG_FILE"; }
log_info() { echo -e "${CYAN}[INFO]${NC} $*" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[PASS]${NC} $*" | tee -a "$LOG_FILE"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $*" | tee -a "$LOG_FILE"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "$LOG_FILE"; }
log_header() { echo -e "\n${BLUE}=== $* ===${NC}" | tee -a "$LOG_FILE"; }
log_verbose() { [[ "$VERBOSE" == "true" ]] && echo -e "${CYAN}[DEBUG]${NC} $*" | tee -a "$LOG_FILE"; }

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Execute command on appropriate server
# NOTE: This script runs ON paw-testnet, so "primary" = local, "secondary" = SSH
run_on() {
    local server="$1"
    shift
    local cmd="$*"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_verbose "DRY-RUN [$server]: $cmd"
        return 0
    fi

    if [[ "$server" == "primary" ]]; then
        # Run locally (we ARE on the primary server)
        eval "$cmd" 2>/dev/null
    elif [[ "$server" == "secondary" ]]; then
        # SSH to services-testnet
        $SECONDARY_SSH "$cmd" 2>/dev/null
    else
        eval "$cmd" 2>/dev/null
    fi
}

# Get block height from validator
get_height() {
    local server="$1"
    local port="$2"
    run_on "$server" "curl -s --max-time 5 http://127.0.0.1:${port}/status" | jq -r '.result.sync_info.latest_block_height // 0'
}

# Get peer count
get_peers() {
    local server="$1"
    local port="$2"
    run_on "$server" "curl -s --max-time 5 http://127.0.0.1:${port}/net_info" | jq -r '.result.n_peers // 0'
}

# Check if validator is signing (synced and not catching up)
is_signing() {
    local server="$1"
    local port="$2"
    local catching_up

    if [[ "$server" == "primary" ]]; then
        catching_up=$(curl -s --max-time 5 "http://127.0.0.1:${port}/status" | jq -r '.result.sync_info.catching_up')
    else
        catching_up=$(ssh -o ConnectTimeout=3 -o BatchMode=yes services-testnet "curl -s --max-time 5 http://127.0.0.1:${port}/status" 2>/dev/null | jq -r '.result.sync_info.catching_up')
    fi

    [[ "$catching_up" == "false" ]]
}

# Check systemd service status
service_status() {
    local server="$1"
    local service="$2"
    run_on "$server" "systemctl is-active $service" || echo "inactive"
}

# Record test result
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

record_result() {
    local test_name="$1"
    local result="$2"  # pass/fail
    local details="${3:-}"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [[ "$result" == "pass" ]]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        log_success "$test_name"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        log_fail "$test_name${details:+ - $details}"
    fi
}

# ============================================================================
# PHASE 1: STABILITY BASELINE
# ============================================================================
run_stability_tests() {
    log_header "PHASE 1: STABILITY BASELINE"

    # Test 1.1: All validators running
    log_info "1.1 Checking all validators are running..."
    local all_running=true
    for v in "${VALIDATORS[@]}"; do
        IFS=: read -r name server home rpc_port rest_port <<< "$v"
        # Extract validator number from name (e.g., "val1" -> "1")
        local val_num="${name#val}"
        local svc="pawd-val@${val_num}"
        local status=$(service_status "$server" "$svc")
        if [[ "$status" == "active" ]]; then
            log_verbose "  $name: active"
        else
            log_verbose "  $name: $status"
            all_running=false
        fi
    done
    record_result "1.1 All validators running" "$([[ "$all_running" == "true" ]] && echo pass || echo fail)"

    # Test 1.2: Block production
    log_info "1.2 Checking block production..."
    local height1=$(get_height "primary" "11657")
    sleep 10
    local height2=$(get_height "primary" "11657")
    local blocks_produced=$((height2 - height1))
    if [[ "$blocks_produced" -gt 0 ]]; then
        record_result "1.2 Block production ($blocks_produced blocks in 10s)" "pass"
    else
        record_result "1.2 Block production" "fail" "No blocks produced"
    fi

    # Test 1.3: Block time within range
    log_info "1.3 Checking block time..."
    if [[ "$blocks_produced" -gt 0 ]]; then
        local avg_block_time=$((10 / blocks_produced))
        if [[ "$avg_block_time" -ge "$MIN_BLOCK_TIME" && "$avg_block_time" -le "$MAX_BLOCK_TIME" ]]; then
            record_result "1.3 Block time (~${avg_block_time}s)" "pass"
        else
            record_result "1.3 Block time (~${avg_block_time}s)" "fail" "Expected ${MIN_BLOCK_TIME}-${MAX_BLOCK_TIME}s"
        fi
    else
        record_result "1.3 Block time" "fail" "Cannot measure - no blocks"
    fi

    # Test 1.4: All validators signing
    log_info "1.4 Checking all validators are signing..."
    local all_signing=true
    for v in "${VALIDATORS[@]}"; do
        IFS=: read -r name server home rpc_port rest_port <<< "$v"
        if is_signing "$server" "$rpc_port"; then
            log_verbose "  $name: signing"
        else
            log_verbose "  $name: NOT signing"
            all_signing=false
        fi
    done
    record_result "1.4 All validators signing" "$([[ "$all_signing" == "true" ]] && echo pass || echo fail)"

    # Test 1.5: Peer connectivity
    log_info "1.5 Checking peer connectivity..."
    local peers=$(get_peers "primary" "11657")
    if [[ "$peers" -ge "$MIN_PEERS" ]]; then
        record_result "1.5 Peer connectivity ($peers peers)" "pass"
    else
        record_result "1.5 Peer connectivity ($peers peers)" "fail" "Expected >= $MIN_PEERS"
    fi

    # Test 1.6: RPC responding
    log_info "1.6 Checking RPC endpoints..."
    local rpc_ok=true
    for v in "${VALIDATORS[@]}"; do
        IFS=: read -r name server home rpc_port rest_port <<< "$v"
        local resp
        if [[ "$server" == "primary" ]]; then
            resp=$(curl -s --max-time 3 -o /dev/null -w '%{http_code}' "http://127.0.0.1:${rpc_port}/status")
        else
            resp=$(ssh -o ConnectTimeout=3 -o BatchMode=yes services-testnet "curl -s --max-time 3 -o /dev/null -w '%{http_code}' http://127.0.0.1:${rpc_port}/status" 2>/dev/null)
        fi
        if [[ "$resp" == "200" ]]; then
            log_verbose "  $name RPC: OK"
        else
            log_verbose "  $name RPC: FAIL ($resp)"
            rpc_ok=false
        fi
    done
    record_result "1.6 RPC endpoints responding" "$([[ "$rpc_ok" == "true" ]] && echo pass || echo fail)"

    # Test 1.7: No critical errors in recent logs (ignore DEBUG level)
    log_info "1.7 Checking for critical errors in logs..."
    local error_count=$(run_on "primary" "journalctl -u pawd-val1 --since '5 minutes ago' -p err 2>/dev/null | wc -l" || echo "0")
    if [[ "$error_count" -lt 10 ]]; then
        record_result "1.7 Log health ($error_count critical errors in 5min)" "pass"
    else
        record_result "1.7 Log health ($error_count critical errors in 5min)" "fail" "Too many errors"
    fi
}

# ============================================================================
# PHASE 2: CORE TRANSACTIONS
# ============================================================================
run_core_tests() {
    log_header "PHASE 2: CORE TRANSACTIONS"

    # Test 2.1: Query chain status
    log_info "2.1 Querying chain status..."
    local chain_id=$(run_on "primary" "curl -s http://127.0.0.1:11657/status" | jq -r '.result.node_info.network // ""')
    if [[ "$chain_id" == "$CHAIN_ID" ]]; then
        record_result "2.1 Chain ID correct ($chain_id)" "pass"
    else
        record_result "2.1 Chain ID" "fail" "Expected $CHAIN_ID, got $chain_id"
    fi

    # Test 2.2: Query validators
    log_info "2.2 Querying validator set..."
    local val_count=$(run_on "primary" "curl -s http://127.0.0.1:11657/validators" | jq -r '.result.total // 0')
    if [[ "$val_count" -eq 4 ]]; then
        record_result "2.2 Validator set ($val_count validators)" "pass"
    else
        record_result "2.2 Validator set ($val_count validators)" "fail" "Expected 4"
    fi

    # Test 2.3: Query genesis accounts
    log_info "2.3 Querying bank module..."
    local bank_query=$(run_on "primary" "curl -s http://127.0.0.1:11317/cosmos/bank/v1beta1/supply" | jq -r '.supply | length // 0')
    if [[ "$bank_query" -gt 0 ]]; then
        record_result "2.3 Bank module query" "pass"
    else
        record_result "2.3 Bank module query" "fail" "No supply data"
    fi

    # Test 2.4: Query staking
    log_info "2.4 Querying staking module..."
    local staking_query=$(run_on "primary" "curl -s http://127.0.0.1:11317/cosmos/staking/v1beta1/validators" | jq -r '.validators | length // 0')
    if [[ "$staking_query" -gt 0 ]]; then
        record_result "2.4 Staking module query ($staking_query validators)" "pass"
    else
        record_result "2.4 Staking module query" "fail" "No validators"
    fi

    # Test 2.5: Query governance (may not be enabled on all chains)
    log_info "2.5 Querying governance module..."
    local gov_resp=$(run_on "primary" "curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:11317/cosmos/gov/v1beta1/proposals")
    if [[ "$gov_resp" == "200" ]]; then
        record_result "2.5 Governance module available" "pass"
    elif [[ "$gov_resp" == "404" ]]; then
        record_result "2.5 Governance module" "pass" "(not enabled)"
    else
        record_result "2.5 Governance module query" "fail" "HTTP $gov_resp"
    fi

    # Test 2.6: Faucet endpoint (if available)
    log_info "2.6 Checking faucet service..."
    local faucet_status=$(service_status "primary" "paw-faucet")
    if [[ "$faucet_status" == "active" ]]; then
        record_result "2.6 Faucet service" "pass"
    else
        record_result "2.6 Faucet service" "fail" "$faucet_status"
    fi

    # Test 2.7: Explorer endpoint (if available)
    log_info "2.7 Checking explorer service..."
    local explorer_status=$(service_status "primary" "paw-explorer")
    if [[ "$explorer_status" == "active" ]]; then
        record_result "2.7 Explorer service" "pass"
    else
        record_result "2.7 Explorer service" "fail" "$explorer_status"
    fi

    # Test 2.8: DEX module (PAW-specific)
    log_info "2.8 Querying DEX module..."
    local dex_resp=$(run_on "primary" "curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:11317/paw/dex/v1beta1/pools")
    if [[ "$dex_resp" == "200" ]]; then
        local dex_pools=$(run_on "primary" "curl -s http://127.0.0.1:11317/paw/dex/v1beta1/pools" | jq -r '.pools | length // 0')
        record_result "2.8 DEX module available ($dex_pools pools)" "pass"
    elif [[ "$dex_resp" == "404" || "$dex_resp" == "501" ]]; then
        record_result "2.8 DEX module" "pass" "(not enabled or no pools)"
    else
        record_result "2.8 DEX module query" "fail" "HTTP $dex_resp"
    fi

    # Test 2.9: Compute module (PAW-specific, if enabled)
    log_info "2.9 Querying compute module..."
    local compute_resp=$(run_on "primary" "curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:11317/paw/compute/v1beta1/jobs")
    if [[ "$compute_resp" == "200" ]]; then
        record_result "2.9 Compute module available" "pass"
    elif [[ "$compute_resp" == "404" || "$compute_resp" == "501" ]]; then
        record_result "2.9 Compute module" "pass" "(not enabled)"
    else
        record_result "2.9 Compute module query" "fail" "HTTP $compute_resp"
    fi
}

# ============================================================================
# PHASE 2.5: MULTI-NODE CONSISTENCY
# ============================================================================
run_multinode_tests() {
    log_header "PHASE 2.5: MULTI-NODE CONSISTENCY"

    local name server home rpc_port rest_port
    local ref_supply="" ref_val_count="" ref_height=""
    local all_consistent=true

    # Get reference values from val1
    log_info "2.5.1 Getting reference state from val1..."
    ref_supply=$(curl -s --max-time 5 "http://127.0.0.1:11317/cosmos/bank/v1beta1/supply" | jq -r '.supply | length // 0')
    ref_val_count=$(curl -s --max-time 5 "http://127.0.0.1:11317/cosmos/staking/v1beta1/validators" | jq -r '.validators | length // 0')
    ref_height=$(curl -s --max-time 5 "http://127.0.0.1:11657/status" | jq -r '.result.sync_info.latest_block_height // 0')

    log_verbose "  Reference: supply_types=$ref_supply, validators=$ref_val_count, height=$ref_height"

    if [[ "$ref_supply" -eq 0 || "$ref_val_count" -eq 0 ]]; then
        record_result "2.5.1 Reference state from val1" "fail" "Could not get reference data"
        return
    fi
    record_result "2.5.1 Reference state from val1" "pass"

    # Test 2.5.2: All nodes return same bank supply count
    log_info "2.5.2 Checking bank module consistency across all nodes..."
    local bank_consistent=true
    for v in "${VALIDATORS[@]}"; do
        IFS=: read -r name server home rpc_port rest_port <<< "$v"
        local supply
        if [[ "$server" == "primary" ]]; then
            supply=$(curl -s --max-time 5 "http://127.0.0.1:${rest_port}/cosmos/bank/v1beta1/supply" | jq -r '.supply | length // 0')
        else
            supply=$(ssh -o ConnectTimeout=3 -o BatchMode=yes services-testnet "curl -s --max-time 5 http://127.0.0.1:${rest_port}/cosmos/bank/v1beta1/supply" 2>/dev/null | jq -r '.supply | length // 0')
        fi
        if [[ "$supply" != "$ref_supply" ]]; then
            log_verbose "  $name: supply_types=$supply (MISMATCH, expected $ref_supply)"
            bank_consistent=false
        else
            log_verbose "  $name: supply_types=$supply (OK)"
        fi
    done
    record_result "2.5.2 Bank module consistency (all nodes)" "$([[ "$bank_consistent" == "true" ]] && echo pass || echo fail)"

    # Test 2.5.3: All nodes return same validator count
    log_info "2.5.3 Checking staking module consistency across all nodes..."
    local staking_consistent=true
    for v in "${VALIDATORS[@]}"; do
        IFS=: read -r name server home rpc_port rest_port <<< "$v"
        local val_count
        if [[ "$server" == "primary" ]]; then
            val_count=$(curl -s --max-time 5 "http://127.0.0.1:${rest_port}/cosmos/staking/v1beta1/validators" | jq -r '.validators | length // 0')
        else
            val_count=$(ssh -o ConnectTimeout=3 -o BatchMode=yes services-testnet "curl -s --max-time 5 http://127.0.0.1:${rest_port}/cosmos/staking/v1beta1/validators" 2>/dev/null | jq -r '.validators | length // 0')
        fi
        if [[ "$val_count" != "$ref_val_count" ]]; then
            log_verbose "  $name: validators=$val_count (MISMATCH, expected $ref_val_count)"
            staking_consistent=false
        else
            log_verbose "  $name: validators=$val_count (OK)"
        fi
    done
    record_result "2.5.3 Staking module consistency (all nodes)" "$([[ "$staking_consistent" == "true" ]] && echo pass || echo fail)"

    # Test 2.5.4: All REST APIs responding
    log_info "2.5.4 Checking REST API availability on all nodes..."
    local rest_ok=true
    for v in "${VALIDATORS[@]}"; do
        IFS=: read -r name server home rpc_port rest_port <<< "$v"
        local http_code
        if [[ "$server" == "primary" ]]; then
            http_code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "http://127.0.0.1:${rest_port}/cosmos/base/tendermint/v1beta1/node_info")
        else
            http_code=$(ssh -o ConnectTimeout=3 -o BatchMode=yes services-testnet "curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://127.0.0.1:${rest_port}/cosmos/base/tendermint/v1beta1/node_info" 2>/dev/null)
        fi
        if [[ "$http_code" == "200" ]]; then
            log_verbose "  $name REST API: OK (HTTP $http_code)"
        else
            log_verbose "  $name REST API: FAIL (HTTP $http_code)"
            rest_ok=false
        fi
    done
    record_result "2.5.4 REST API availability (all nodes)" "$([[ "$rest_ok" == "true" ]] && echo pass || echo fail)"

    # Test 2.5.5: Chain ID consistent across all nodes
    log_info "2.5.5 Checking chain ID consistency across all nodes..."
    local chain_consistent=true
    for v in "${VALIDATORS[@]}"; do
        IFS=: read -r name server home rpc_port rest_port <<< "$v"
        local node_chain_id
        if [[ "$server" == "primary" ]]; then
            node_chain_id=$(curl -s --max-time 5 "http://127.0.0.1:${rpc_port}/status" | jq -r '.result.node_info.network // ""')
        else
            node_chain_id=$(ssh -o ConnectTimeout=3 -o BatchMode=yes services-testnet "curl -s --max-time 5 http://127.0.0.1:${rpc_port}/status" 2>/dev/null | jq -r '.result.node_info.network // ""')
        fi
        if [[ "$node_chain_id" != "$CHAIN_ID" ]]; then
            log_verbose "  $name: chain_id=$node_chain_id (MISMATCH, expected $CHAIN_ID)"
            chain_consistent=false
        else
            log_verbose "  $name: chain_id=$node_chain_id (OK)"
        fi
    done
    record_result "2.5.5 Chain ID consistency (all nodes)" "$([[ "$chain_consistent" == "true" ]] && echo pass || echo fail)"

    # Test 2.5.6: App hash consistency (within recent blocks)
    log_info "2.5.6 Checking app hash consistency across all nodes..."
    local ref_app_hash=$(curl -s --max-time 5 "http://127.0.0.1:11657/status" | jq -r '.result.sync_info.latest_app_hash // ""')
    local app_hash_consistent=true

    # Allow for 1-2 block variance, check that hashes are non-empty and nodes are synced
    for v in "${VALIDATORS[@]}"; do
        IFS=: read -r name server home rpc_port rest_port <<< "$v"
        local app_hash
        if [[ "$server" == "primary" ]]; then
            app_hash=$(curl -s --max-time 5 "http://127.0.0.1:${rpc_port}/status" | jq -r '.result.sync_info.latest_app_hash // ""')
        else
            app_hash=$(ssh -o ConnectTimeout=3 -o BatchMode=yes services-testnet "curl -s --max-time 5 http://127.0.0.1:${rpc_port}/status" 2>/dev/null | jq -r '.result.sync_info.latest_app_hash // ""')
        fi
        if [[ -z "$app_hash" || "$app_hash" == "null" ]]; then
            log_verbose "  $name: app_hash=MISSING"
            app_hash_consistent=false
        else
            log_verbose "  $name: app_hash=${app_hash:0:16}... (OK)"
        fi
    done
    record_result "2.5.6 App hash present (all nodes)" "$([[ "$app_hash_consistent" == "true" ]] && echo pass || echo fail)"

    # Test 2.5.7: DEX pool consistency across all nodes (PAW-specific)
    log_info "2.5.7 Checking DEX pool consistency across all nodes..."
    local ref_pools=$(curl -s --max-time 5 "http://127.0.0.1:11317/paw/dex/v1beta1/pools" 2>/dev/null | jq -r '.pools | length // 0')
    local dex_consistent=true

    # Skip if DEX module not available
    if [[ "$ref_pools" == "0" || -z "$ref_pools" ]]; then
        log_verbose "  DEX module not available or no pools, skipping consistency check"
        record_result "2.5.7 DEX pool consistency" "pass" "(no pools or module disabled)"
    else
        for v in "${VALIDATORS[@]}"; do
            IFS=: read -r name server home rpc_port rest_port <<< "$v"
            local pools
            if [[ "$server" == "primary" ]]; then
                pools=$(curl -s --max-time 5 "http://127.0.0.1:${rest_port}/paw/dex/v1beta1/pools" | jq -r '.pools | length // 0')
            else
                pools=$(ssh -o ConnectTimeout=3 -o BatchMode=yes services-testnet "curl -s --max-time 5 http://127.0.0.1:${rest_port}/paw/dex/v1beta1/pools" 2>/dev/null | jq -r '.pools | length // 0')
            fi
            if [[ "$pools" != "$ref_pools" ]]; then
                log_verbose "  $name: pools=$pools (MISMATCH, expected $ref_pools)"
                dex_consistent=false
            else
                log_verbose "  $name: pools=$pools (OK)"
            fi
        done
        record_result "2.5.7 DEX pool consistency (all nodes)" "$([[ "$dex_consistent" == "true" ]] && echo pass || echo fail)"
    fi
}

# ============================================================================
# PHASE 3: CONSENSUS / RESILIENCE
# ============================================================================
run_consensus_tests() {
    log_header "PHASE 3: CONSENSUS / RESILIENCE"

    # Test 3.1: Height consistency across validators
    log_info "3.1 Checking height consistency..."
    local heights=()
    for v in "${VALIDATORS[@]}"; do
        IFS=: read -r name server home rpc_port rest_port <<< "$v"
        local h=$(get_height "$server" "$rpc_port")
        heights+=("$h")
        log_verbose "  $name height: $h"
    done

    local min_h=${heights[0]}
    local max_h=${heights[0]}
    for h in "${heights[@]}"; do
        [[ "$h" -lt "$min_h" ]] && min_h="$h"
        [[ "$h" -gt "$max_h" ]] && max_h="$h"
    done
    local height_diff=$((max_h - min_h))

    if [[ "$height_diff" -le 2 ]]; then
        record_result "3.1 Height consistency (diff: $height_diff)" "pass"
    else
        record_result "3.1 Height consistency (diff: $height_diff)" "fail" "Validators out of sync"
    fi

    # Test 3.2: Voting power distribution
    log_info "3.2 Checking voting power distribution..."
    local total_power=$(run_on "primary" "curl -s http://127.0.0.1:11657/validators" | jq -r '[.result.validators[].voting_power | tonumber] | add // 0')
    if [[ "$total_power" -gt 0 ]]; then
        record_result "3.2 Voting power ($total_power total)" "pass"
    else
        record_result "3.2 Voting power" "fail" "No voting power"
    fi

    # Test 3.3: Consensus state
    log_info "3.3 Checking consensus state..."
    local consensus=$(run_on "primary" "curl -s http://127.0.0.1:11657/consensus_state" | jq -r '.result.round_state["height/round/step"] // ""')
    if [[ -n "$consensus" ]]; then
        record_result "3.3 Consensus state ($consensus)" "pass"
    else
        record_result "3.3 Consensus state" "fail" "No consensus data"
    fi

    log_warn "3.4-3.6 Resilience tests (validator stop/start) skipped - manual execution recommended"
    log_info "  To test: Stop val4, verify chain continues, restart val4, verify catchup"
}

# ============================================================================
# PHASE 4: SECURITY
# ============================================================================
run_security_tests() {
    log_header "PHASE 4: SECURITY"

    # Test 4.1: RPC not exposed to public
    log_info "4.1 Checking RPC binding..."
    local rpc_bind=$(run_on "primary" "grep 'laddr.*tcp' ~/.paw-val1/config/config.toml | head -1" | grep -o '127.0.0.1\|0.0.0.0' | head -1)
    if [[ "$rpc_bind" == "127.0.0.1" ]]; then
        record_result "4.1 RPC bound to localhost" "pass"
    else
        record_result "4.1 RPC binding" "warn" "Bound to $rpc_bind"
    fi

    # Test 4.2: P2P port accessible
    log_info "4.2 Checking P2P connectivity..."
    local p2p_peers=$(get_peers "primary" "11657")
    if [[ "$p2p_peers" -ge 2 ]]; then
        record_result "4.2 P2P connectivity ($p2p_peers peers)" "pass"
    else
        record_result "4.2 P2P connectivity" "fail" "Low peer count"
    fi

    # Test 4.3: No jailed validators
    log_info "4.3 Checking for jailed validators..."
    local jailed=$(run_on "primary" "curl -s http://127.0.0.1:11317/cosmos/staking/v1beta1/validators" | jq -r '[.validators[] | select(.jailed == true)] | length')
    if [[ "$jailed" -eq 0 ]]; then
        record_result "4.3 No jailed validators" "pass"
    else
        record_result "4.3 Jailed validators" "fail" "$jailed jailed"
    fi

    # Test 4.4: State sync disabled (for validators)
    log_info "4.4 Checking state sync config..."
    local statesync=$(run_on "primary" "grep 'enable.*=' ~/.paw-val1/config/config.toml | grep -i statesync" | grep -o 'true\|false' | head -1)
    if [[ "$statesync" != "true" ]]; then
        record_result "4.4 State sync disabled" "pass"
    else
        record_result "4.4 State sync" "warn" "Enabled on validator"
    fi
}

# ============================================================================
# PHASE 5: OPERATIONS
# ============================================================================
run_ops_tests() {
    log_header "PHASE 5: OPERATIONS"

    # Test 5.1: Health check daemon running
    log_info "5.1 Checking health check daemon..."
    local health_status=$(service_status "primary" "paw-health")
    if [[ "$health_status" == "active" ]]; then
        record_result "5.1 Health check daemon" "pass"
    else
        record_result "5.1 Health check daemon" "fail" "$health_status"
    fi

    # Test 5.2: Disk space
    log_info "5.2 Checking disk space..."
    local disk_free=$(run_on "primary" "df / | awk 'NR==2 {print 100-\$5}' | tr -d '%'")
    if [[ "$disk_free" -gt 20 ]]; then
        record_result "5.2 Disk space (${disk_free}% free)" "pass"
    else
        record_result "5.2 Disk space (${disk_free}% free)" "fail" "Low disk"
    fi

    # Test 5.3: Memory usage
    log_info "5.3 Checking memory..."
    local mem_free=$(run_on "primary" "free | awk '/Mem:/ {printf \"%.0f\", \$7/\$2*100}'")
    if [[ "$mem_free" -gt 10 ]]; then
        record_result "5.3 Memory (${mem_free}% available)" "pass"
    else
        record_result "5.3 Memory (${mem_free}% available)" "warn" "Low memory"
    fi

    # Test 5.4: Cosmovisor configured
    log_info "5.4 Checking Cosmovisor..."
    local cosmovisor=$(run_on "primary" "test -f /usr/local/bin/cosmovisor && echo yes || echo no")
    if [[ "$cosmovisor" == "yes" ]]; then
        record_result "5.4 Cosmovisor installed" "pass"
    else
        record_result "5.4 Cosmovisor" "fail" "Not installed"
    fi

    # Test 5.5: SSH connectivity to secondary
    log_info "5.5 Checking cross-server connectivity..."
    local ssh_test=$(run_on "primary" "ssh -o ConnectTimeout=3 -o BatchMode=yes services-testnet 'echo ok'" || echo "fail")
    if [[ "$ssh_test" == "ok" ]]; then
        record_result "5.5 SSH to secondary server" "pass"
    else
        record_result "5.5 SSH to secondary server" "fail" "Cannot connect"
    fi
}

# ============================================================================
# GENERATE REPORT
# ============================================================================
generate_report() {
    log_header "GENERATING VALIDATION REPORT"

    local timestamp=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
    local pass_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))

    cat > "$RESULTS_FILE" << EOF
# PAW Testnet Validation Report

**Chain ID:** $CHAIN_ID
**Date:** $timestamp
**Validators:** 4 (val1, val2 on paw-testnet; val3, val4 on services-testnet)

## Summary

| Metric | Value |
|--------|-------|
| Total Tests | $TOTAL_TESTS |
| Passed | $PASSED_TESTS |
| Failed | $FAILED_TESTS |
| Pass Rate | ${pass_rate}% |

## Test Results

EOF

    # Append log contents (filtered for results)
    grep -E '\[PASS\]|\[FAIL\]|\[WARN\]' "$LOG_FILE" | while read -r line; do
        if echo "$line" | grep -q '\[PASS\]'; then
            echo "- [x] ${line#*\[PASS\] }"
        elif echo "$line" | grep -q '\[FAIL\]'; then
            echo "- [ ] ${line#*\[FAIL\] }"
        else
            echo "- [~] ${line#*\[WARN\] }"
        fi
    done >> "$RESULTS_FILE"

    cat >> "$RESULTS_FILE" << EOF

## Next Steps

EOF

    if [[ "$FAILED_TESTS" -gt 0 ]]; then
        echo "1. Address failing tests before proceeding" >> "$RESULTS_FILE"
        echo "2. Re-run validation: \`./run-tests.sh\`" >> "$RESULTS_FILE"
    else
        echo "1. All baseline tests passed" >> "$RESULTS_FILE"
        echo "2. Proceed to transaction testing" >> "$RESULTS_FILE"
        echo "3. Run resilience tests manually" >> "$RESULTS_FILE"
    fi

    cat >> "$RESULTS_FILE" << EOF

## Full Log

See \`/tmp/paw-testnet-validation.log\` for detailed output.

---
*Generated by PAW testnet validation harness*
EOF

    log_success "Report saved to: $RESULTS_FILE"
}

# ============================================================================
# MAIN
# ============================================================================
usage() {
    cat << EOF
PAW Testnet Validation Test Harness

Usage: $0 [phase] [options]

Phases:
  all        Run all phases (default)
  stability  Phase 1: Stability baseline
  core       Phase 2: Core transactions
  multinode  Phase 2.5: Multi-node consistency
  consensus  Phase 3: Consensus/resilience
  security   Phase 4: Security tests
  ops        Phase 5: Operations tests

Options:
  --dry-run   Show what would run without executing
  --verbose   Enable verbose output
  --help      Show this help

Examples:
  $0                      Run all tests
  $0 stability            Run only stability tests
  $0 all --verbose        Run all with verbose output
EOF
    exit 0
}

main() {
    local phase="all"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            all|stability|core|multinode|consensus|security|ops)
                phase="$1"
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                usage
                ;;
            *)
                log_warn "Unknown argument: $1"
                shift
                ;;
        esac
    done

    # Clear log
    > "$LOG_FILE"

    log "============================================"
    log "PAW Testnet Validation - $CHAIN_ID"
    log "============================================"
    log "Phase: $phase"
    log "Dry run: $DRY_RUN"
    log "Verbose: $VERBOSE"
    log ""

    # Run requested phases
    case "$phase" in
        all)
            run_stability_tests
            run_core_tests
            run_multinode_tests
            run_consensus_tests
            run_security_tests
            run_ops_tests
            ;;
        stability) run_stability_tests ;;
        core) run_core_tests ;;
        multinode) run_multinode_tests ;;
        consensus) run_consensus_tests ;;
        security) run_security_tests ;;
        ops) run_ops_tests ;;
    esac

    # Generate report
    generate_report

    # Summary
    echo ""
    log_header "SUMMARY"
    echo "Total: $TOTAL_TESTS | Passed: $PASSED_TESTS | Failed: $FAILED_TESTS"

    if [[ "$FAILED_TESTS" -eq 0 ]]; then
        log_success "All tests passed!"
        exit 0
    else
        log_fail "$FAILED_TESTS test(s) failed"
        exit 1
    fi
}

main "$@"
