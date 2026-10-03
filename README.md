# 3xFactor node

Agent for a 3x-ui node. The license stays on the master 3xFactor panel. This installer asks for a one-time code from that panel (Nodes page) and pairs this server.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/neoauroraproject/3xfactor-node/main/install.sh)
```

`PAIR_CODE='XFNODE...'` skips the prompt. Running it again re-pairs without removing the Xray patch. `update` replaces the agent binary and keeps the pairing.

The master panel must be able to reach port `28452` on this server.
