#!/usr/bin/env bash
# Destroy and recreate this stack. Terraform asks for its own confirmation.
set -euo pipefail
cd "$(dirname "$0")"

if [[ -f backend.hcl.example ]]; then
  if [[ ! -f backend.hcl ]]; then
    echo "Copy backend.hcl.example to backend.hcl and edit the bucket name first." >&2
    exit 1
  fi
  terraform init -input=false -backend-config=backend.hcl
else
  terraform init -input=false
fi

terraform destroy
terraform apply
