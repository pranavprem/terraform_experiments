#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if [[ ! -f backend.hcl ]]; then
  echo "Copy backend.hcl.example to backend.hcl and edit the bucket name first." >&2
  exit 1
fi
terraform init -input=false -backend-config=backend.hcl

url="$(terraform output -raw app_url)"
curl --fail --show-error --max-time 15 "${url}"
