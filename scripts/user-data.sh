#!/bin/bash
# Install Node and start https://github.com/pranavprem/ReactCalculator on port 8080.
# Cloud-init runs this once, as root, on Ubuntu.
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates curl git xz-utils

NODE_VERSION="22.23.3"
case "$(uname -m)" in
  x86_64)
    NODE_ARCH="x64"
    NODE_SHA256="df450af89261115ef9f9e3830c3eeb2cc9213b63c720b1af623cb5dcbe2e02de"
    ;;
  aarch64)
    NODE_ARCH="arm64"
    NODE_SHA256="a44aeb94849a299b22df10b9e622ec2f605c2183501bc40590705131de7c740f"
    ;;
  *)
    echo "unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

tmp="$(mktemp)"
curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" -o "${tmp}"
echo "${NODE_SHA256}  ${tmp}" | sha256sum -c -
tar -xJf "${tmp}" -C /usr/local --strip-components=1
rm -f "${tmp}"

rm -rf /opt/ReactCalculator
git clone --depth 1 https://github.com/pranavprem/ReactCalculator.git /opt/ReactCalculator
cd /opt/ReactCalculator
# The upstream tree vendors node_modules. Reinstall so this instance gets Linux copies.
rm -rf node_modules
# Webpack 1 hashes with MD4, which Node 17+ exposes only through the legacy provider.
export NODE_OPTIONS=--openssl-legacy-provider
npm install --unsafe-perm --legacy-peer-deps

cat > /etc/systemd/system/react-calculator.service <<'UNIT'
[Unit]
Description=React Calculator dev server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=/opt/ReactCalculator
Environment=NODE_OPTIONS=--openssl-legacy-provider
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=/usr/local/bin/npm run dev
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now react-calculator.service
