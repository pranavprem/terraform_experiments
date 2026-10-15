#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

key_file="${HOME}/react_calculator_key_pair.pem"
umask 077
terraform output -raw private_key > "${key_file}"
chmod 400 "${key_file}"

dns="$(terraform output -raw public_dns)"
exec ssh -i "${key_file}" -o StrictHostKeyChecking=accept-new "ubuntu@${dns}"
