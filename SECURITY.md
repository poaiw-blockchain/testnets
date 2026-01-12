# Security Policy

## Scope

This repository contains **network configuration files** for PAW testnets,
including genesis files, peer information, and chain registry metadata.

For security issues in the **PAW blockchain code itself**, please report to the
[main PAW repository](https://github.com/poaiw-blockchain/paw/security).

## Reporting a Vulnerability

### Network Configuration Issues

If you discover a security issue in the network configuration (e.g., malicious
peer information, compromised genesis data):

1. **DO NOT** open a public issue
2. Email: **info@poaiw.org**
3. Include:
   - Description of the issue
   - Which files are affected
   - Potential impact
   - Steps to reproduce (if applicable)

### Response Timeline

- **Acknowledgment**: Within 48 hours
- **Initial assessment**: Within 7 days
- **Resolution**: Varies based on severity

## What to Report

### In Scope (This Repository)

- Malicious or compromised peer/seed information
- Invalid or tampered genesis files
- Incorrect IBC channel configurations that could cause issues
- Exposed sensitive information in configuration files

### Out of Scope

- Code vulnerabilities in PAW blockchain (report to main repo)
- Issues with your own node setup
- General questions about configuration

## Testnet Notice

This repository contains **testnet** configurations. While we take security
seriously, testnets are experimental environments. No real assets should be
at risk.

## Contact

- **Email**: info@poaiw.org
- **Main repo security**: https://github.com/poaiw-blockchain/paw/security

Thank you for helping keep PAW secure.
