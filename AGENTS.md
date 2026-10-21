# Agent guide

This repo is a set of small, independent Terraform roots that deploy [pranavprem/ReactCalculator](https://github.com/pranavprem/ReactCalculator). Read [README.md](README.md) for the history and the apply order. This file is how to change the repo safely.

## Architecture

Three generations, one experiment. They share names (`react_calculator_sg`, `react-calculator`, `react-calculator-asg`) and will collide if applied together in one account and region.

| Root | Creates | State |
| --- | --- | --- |
| `simple_server/` | Key pair, security group, one instance | Local |
| `multiserver_loadbalancer/` | Key pair, security groups, launch template, ASG, ALB | Local |
| `remote_state/remote_state_store/` | Versioned encrypted S3 bucket, DynamoDB lock table | Local on first apply, then the bucket it created |
| `remote_state/launch_config/` | Key pair, instance security group, launch template | S3 key `global/s3/terraform-launch-config.tfstate` |
| `remote_state/autoscaling_loadbalancing/` | ALB security group, ASG, ALB | S3 key `global/s3/terraform-autoscaling-loadbalancing.tfstate` |

`autoscaling_loadbalancing` reads `launch_template_id` and `server_port` from the launch_config state. The directory is still named `launch_config` even though the resource is an `aws_launch_template`.

The instance boot script is `scripts/user-data.sh` only. `simple_server` and `multiserver_loadbalancer` read it via `path.module/../scripts/user-data.sh`. `remote_state/launch_config` reads it via `path.module/../../scripts/user-data.sh`. Launch templates base64-encode that file. The single `aws_instance` does not.

There is no shared Terraform module. Duplicated variables and the repeated AMI lookup are intentional: each directory has to stay a root you can `init` on its own.

## Conventions

- Terraform `>= 1.16.6, < 1.17.0`. The CI pin and `.terraform-version` are `1.16.6`.
- Providers are exact: `hashicorp/aws` `6.68.0`, `hashicorp/tls` `4.4.1` where a key pair exists. Commit `.terraform.lock.hcl`. Regenerate every platform with `make lock`.
- `terraform fmt -recursive` is the formatter. Indent HCL with two spaces.
- Region comes from `var.aws_region` (default `us-east-1`). Do not hardcode credentials, access keys, or secret keys. The AWS provider uses the standard environment and shared config.
- Remote backend blocks stay empty. Real values belong in `backend.hcl`, copied from `backend.hcl.example` and gitignored. Backend blocks cannot take variables, so `var.aws_region`, `var.state_bucket`, and `backend.hcl` must be kept in agreement by hand.
- Shell scripts are bash, `set -euo pipefail`, and executable.
- Do not add a license file.
- Do not commit `.terraform/`, `*.tfstate`, `*.tfplan`, `backend.hcl`, or `*.pem`.

## Commands

```bash
make fmt          # terraform fmt -recursive
make fmt-check    # CI formatting check
make validate     # init -backend=false and validate every root
make lock         # refresh .terraform.lock.hcl for linux, darwin, and windows
```

Per stack, after a real backend exists:

```bash
terraform -chdir=simple_server init
terraform -chdir=simple_server apply
```

Remote roots:

```bash
terraform -chdir=remote_state/launch_config init -backend-config=backend.hcl
```

The first apply of `remote_state/remote_state_store` is `terraform init -backend=false`, then apply, then `terraform init -backend-config=backend.hcl -migrate-state`. The bucket has `prevent_destroy`.

GitHub Actions (`.github/workflows/terraform.yml`) runs `make fmt-check` and `make validate` on pull requests and on pushes to `main`. It does not plan or apply. The stack list in the Makefile is the list CI validates.

## Hard rules

- Do not run `terraform plan` or `terraform apply` against a real AWS account from this repo unless the user explicitly asks for that apply and names the account. `init -backend=false`, `fmt`, `validate`, and `providers lock` are the safe commands. They talk to the Terraform registry, not to AWS.
- Do not run `terraform destroy` against a real account unless the user explicitly asks.
- If you find a hardcoded credential, including in git history or a committed state file, remove it, switch the config to environment variables, and say so at the top of the pull request. A scan of this history in the 2026 refresh found none. Generated SSH private keys still land in Terraform state at apply time. That is the original design. Keep state local or in the encrypted bucket, and never commit it.

## Gotchas

- **Default VPC.** Both load-balanced roots look up the default VPC and its subnets. An account without one will not apply.
- **Open security groups.** Ports 22 and 8080 on instances, and port 80 on the load balancer, allow `0.0.0.0/0`. Leave that behavior unless you are asked to change the sandbox. Call it out if you do.
- **Boot time.** User data downloads Node and runs `npm install` before systemd starts the app. The ASG grace period is 600 seconds and the health check expects HTTP 200 on `/`. Shortening the grace period marks instances unhealthy while they are still installing.
- **Old application.** The calculator is Webpack 1. `npm install` needs `--legacy-peer-deps`. Node 17+ needs `NODE_OPTIONS=--openssl-legacy-provider`. Ubuntu's `apt` Node package is the wrong place to "simplify" this. To retest the app without AWS:

  ```bash
  git clone --depth 1 https://github.com/pranavprem/ReactCalculator.git /tmp/ReactCalculator
  cd /tmp/ReactCalculator && rm -rf node_modules
  NODE_OPTIONS=--openssl-legacy-provider npm install --unsafe-perm --legacy-peer-deps
  NODE_OPTIONS=--openssl-legacy-provider npm run dev
  curl -fsS http://127.0.0.1:8080/
  ```

  A request with an ALB-style `Host` header must also return 200. The app sets `disableHostCheck` for that.
- **Launch template user data is base64.** The `aws_instance` user data is plain text. Mixing those up produces instances that never boot the script.
- **`$Latest`.** The ASG launch template version is the literal string `$Latest`. HCL does not interpolate it. Keep the quotes.
- **ELB health checks.** `health_check_type = "ELB"` is what replaces a dead app process. Dropping it puts the group back on EC2 checks only, which stay green while the calculator is down.
- **State bucket.** `prevent_destroy` blocks `terraform destroy`. Versioning means the bucket must be emptied, including old versions, before AWS will delete it. The public access block is there because this bucket holds state, including an SSH private key.
- **Sensitive outputs.** `terraform output private_key` redacts the value. Scripts use `terraform output -raw`. The old `sed` trimming assumed Terraform 0.12's heredoc printing and corrupts the PEM today.
- **`make validate` uses `-backend=false`.** Run a normal `terraform init` before apply. Remote roots need `-backend-config=backend.hcl`.
- **`redeploy.sh` destroys.** It runs `terraform destroy` and then `terraform apply`, with Terraform's own confirmations. It is not a safe helper to invoke from CI.
- **S3 backend chicken and egg.** `remote_state_store` cannot `init` against its bucket until that bucket exists. Follow the README order.
- **Instance type.** The default is still `t2.micro`, matching 2020. It is an `instance_type` variable if a region has no t2.
