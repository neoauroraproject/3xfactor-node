#!/usr/bin/env bash
# 3xFactor node
#   bash <(curl -fsSL https://raw.githubusercontent.com/neoauroraproject/3xfactor-node/main/install.sh)
#   PAIR_CODE='XFNODE...' bash <(curl -fsSL https://raw.githubusercontent.com/neoauroraproject/3xfactor-node/main/install.sh)
#   bash <(curl -fsSL https://raw.githubusercontent.com/neoauroraproject/3xfactor-node/main/install.sh) update
set -euo pipefail

RELEASES="https://github.com/neoauroraproject/3xfactor-node/releases/latest/download"
INSTALLED="/usr/local/3xfactor-node/3xfactor-node"

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this installer as root." >&2
  exit 1
fi

case "$(uname -m)" in
  x86_64|amd64)   ARCH="amd64" ;;
  aarch64|arm64)  ARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi

TTY=/dev/tty
[ -r "$TTY" ] || TTY=/dev/stdin

download_release() {
  local dest
  dest="$(mktemp /tmp/3xfactor-node.XXXXXX)"
  echo "Downloading 3xFactor node for linux-$ARCH ..." >&2
  if ! curl -fsSL --retry 3 --connect-timeout 20 -o "$dest" "$RELEASES/3xfactor-node-linux-$ARCH"; then
    rm -f "$dest"
    echo "Download failed." >&2
    exit 1
  fi
  if [ "$(head -c 4 "$dest" | od -An -tx1 | tr -d ' \n')" != "7f454c46" ]; then
    rm -f "$dest"
    echo "Downloaded file is not a Linux binary." >&2
    exit 1
  fi
  chmod +x "$dest"
  printf '%s\n' "$dest"
}

CMD="${1:-install}"
case "$CMD" in
  install)
    BIN="$(download_release)"
    trap 'rm -f "$BIN"' EXIT
    if [ -f /etc/3xfactor-node/agent.json ]; then
      echo "3xFactor node is already installed. Re-pairing keeps the Xray patch and current ratios." >&2
    fi
    PAIR_CODE="${PAIR_CODE:-}" "$BIN" node install <"$TTY"
    ;;
  update)
    if [ ! -x "$INSTALLED" ]; then
      echo "3xFactor node is not installed. Run the installer with no arguments first." >&2
      exit 1
    fi
    BIN="$(download_release)"
    trap 'rm -f "$BIN"' EXIT
    install -m 0755 "$BIN" "$INSTALLED"
    systemctl restart 3xfactor-node
    echo "3xFactor node updated. The pairing was not changed."
    ;;
  *)
    echo "Unknown command: $CMD (install | update)" >&2
    exit 1
    ;;
esac
