# PAW Testnet Infrastructure Issues

## Issue #1: Funded Account Keys Not Accessible

**Discovered:** 2026-01-09 during comprehensive testing

**Impact:** Transaction tests, faucet operations, and any test requiring funded accounts cannot execute.

### Problem
The testnet was initialized with validator and faucet accounts that have significant balances, but the mnemonics/private keys were not recorded:

| Address | Balance | Key Status |
|---------|---------|------------|
| pawtest19dmf24wfr4vch2senrh8pqm3r6yr9ae9mxgdvc | 750,000 PAW | Key not accessible |
| pawtest1n7uh7eslpjwvtnexymk9r7gueh9j6fx987h8hd | 750,000 PAW | Key not accessible |
| pawtest1c5l08j0ct6rhfr9gpnx9pz5lvgyp87y0fuk0dx | 750,000 PAW | Key not accessible |
| pawtest1m30wwlma6s4uyzw2g42tdl87pt53r094qql38a | 750,000 PAW | Key not accessible |
| pawtest1fl48vsnmsdzcv85q5d2q4z5ajdha8yu3l8u3uf | 1,000,000 PAW | Key not accessible (faucet) |

### Root Cause
- Validators were created with `--keyring-backend os` but system keyring is empty on headless server
- Mnemonics were not recorded in SOPS (`secrets/testnet.yaml`)
- The `.address` files in keyring-test are encrypted JWE without passphrase access

### Fix Options

**Option A: Genesis Upgrade (Recommended)**
1. Export current state: `pawd export > genesis_export.json`
2. Stop all validators
3. Modify genesis to add funds to new account with known mnemonic
4. Reset validator state and restart with new genesis
5. Record new mnemonic in SOPS

**Option B: Governance Proposal**
- Submit community pool spend proposal to fund new faucet
- Requires validator voting (but we don't have voting account access)

**Option C: Chain Reset**
- Complete reset with new genesis
- Properly record all mnemonics in SOPS
- Most disruptive but cleanest solution

### Immediate Workaround
- Skip transaction-dependent tests with clear documentation
- Continue with infrastructure/resilience tests that don't require funds
- Fix infrastructure issue before production launch

### Action Items
- [ ] Choose fix option
- [ ] Record all account mnemonics in SOPS during fix
- [ ] Update faucet configuration with new key
- [ ] Re-run comprehensive test suite

## Issue #2: Address Prefix Mismatch (FIXED)

**Status:** Resolved 2026-01-09

The pawd binary was using `paw` prefix but chain genesis uses `pawtest` prefix.

**Fix Applied:**
- Updated `app/params.go` to use `pawtest` prefix
- Rebuilt pawd binary
- Updated faucet binary address validation regex
