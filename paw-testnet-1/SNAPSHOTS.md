# Snapshots (paw-testnet-1)

Chain data snapshots for faster sync (~30 minutes).

## Download

```bash
sudo systemctl stop pawd
cd $HOME/.paw
curl -sL https://testnet-rpc.poaiw.org/files/snapshots/latest.tar.lz4 | lz4 -dc | tar -xf -
sudo systemctl start pawd
```

## Info

- **URL**: https://testnet-rpc.poaiw.org/files/snapshots/
- **Format**: lz4 compressed tar
- **Update**: Every 12 hours
