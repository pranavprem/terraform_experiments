# terraform_experiments

Experiments from the end of 2020 that deploy [ReactCalculator](https://github.com/pranavprem/ReactCalculator) on EC2. One instance comes first, then an Auto Scaling group behind an Application Load Balancer, then the same load-balanced setup split across roots that share state in S3.

The calculator is a small React 0.14 app. Terraform's job is to boot it and put it on a public URL.

## Original context

Pranav Prem wrote this between 29 December 2020 and 2 January 2021, and the repo then sat untouched. The commits are the design:

| Date | Commit | What it added |
| --- | --- | --- |
| 2020-12-29 | `9197822` | A single EC2 instance |
| 2020-12-29 | `c41c501` | User data that clones the calculator and runs `npm run dev` |
| 2020-12-30 | `644e4fe` | An Auto Scaling group and an Application Load Balancer |
| 2021-01-02 | `34aa1ae` | Three roots under `remote_state/` that share an S3 backend and a DynamoDB lock table |

The same day as the user-data commit, [ReactCalculator](https://github.com/pranavprem/ReactCalculator) was changed to bind webpack-dev-server on `0.0.0.0:8080` and turn off its host check, so a public instance could serve the page. The layout follows the usual single-server, then load-balanced autoscaling, then remote-state progression (the shape popularized by *Terraform: Up & Running*). Resource names still say `react_calculator`.

## How it works

Each directory under the repo root is its own Terraform root. They are three generations of the same experiment. Applying more than one generation in the same account and region collides on security group, key pair, launch template, and load balancer names.

**`simple_server/`** creates a key pair, a security group, and one instance in the default VPC. User data installs Node, clones the calculator, and systemd runs `npm run dev` on port 8080. The security group opens 8080 and 22 to the internet. You open `http://<public-dns>:8080/`.

**`multiserver_loadbalancer/`** replaces that instance with a launch template, an Auto Scaling group (minimum 2, maximum 10), and an Application Load Balancer. The load balancer listens on port 80 and forwards every path to the instances on 8080. A fixed 404 response remains as the listener's default action for when the forward rule is absent. Health checks request `/` and expect HTTP 200. The group uses ELB health checks and waits 600 seconds before acting on them, which covers the boot script.

**`remote_state/`** splits the load-balanced generation into three roots:

1. `remote_state_store/` creates the S3 bucket (versioned, encrypted, not public) and the DynamoDB lock table.
2. `launch_config/` creates the key pair, instance security group, and launch template, and writes its state to S3. The directory keeps its original name.
3. `autoscaling_loadbalancing/` reads that state with `terraform_remote_state` and creates the Auto Scaling group, target group, and load balancer.

The launch template id and the server port cross the boundary as outputs. Everything else in the autoscaling root is local to that state file.

`scripts/user-data.sh` is the boot script for every generation. It installs Node.js 22.23.3 from nodejs.org (checksum checked), reinstalls the calculator's dependencies, and starts a systemd unit. Webpack 1 needs `NODE_OPTIONS=--openssl-legacy-provider` on this Node version. The app listens on 8080, which is webpack-dev-server's default and the `server_port` variable.

SSH uses a key Terraform generates with the TLS provider. The private key is a sensitive output and lives in state. `simple_server/ssh_to_host.sh` writes it to `~/react_calculator_key_pair.pem` and connects as `ubuntu`.

## Project structure

```
.
├── scripts/user-data.sh          # shared instance boot script
├── simple_server/                # one EC2 instance
├── multiserver_loadbalancer/     # launch template, ASG, and ALB in one state
└── remote_state/
    ├── remote_state_store/       # S3 bucket and DynamoDB lock table
    ├── launch_config/            # launch template, written to remote state
    └── autoscaling_loadbalancing/ # ASG and ALB, reads the launch template from remote state
```

Each root has its own `versions.tf`, variables, and outputs. The remote roots also have `backend.tf` plus `backend.hcl.example`.

## Tech stack

| Piece | Version |
| --- | --- |
| Terraform | 1.16.6 (`>= 1.16.6, < 1.17.0`; see `.terraform-version`) |
| hashicorp/aws | 6.68.0 |
| hashicorp/tls | 4.4.1 |
| Instance image | Ubuntu 24.04 LTS, current Canonical AMI in the selected region |
| Node on the instance | 22.23.3 |
| Application | React 0.14, Webpack 1.15, webpack-dev-server, port 8080 |

Provider versions are pinned in each root and recorded in the committed `.terraform.lock.hcl` files. AWS credentials are whatever the normal SDK chain already has (`AWS_PROFILE`, or `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`). The configuration sets the region itself, default `us-east-1`.

## Run it today

You need Terraform 1.16.6, an AWS account with a default VPC in the chosen region, and credentials in the environment. These stacks create real resources. An Application Load Balancer is billed by the hour, and the autoscaling stacks start two instances. Destroy the stack when you are done looking at it.

Check formatting and configuration without talking to AWS:

```bash
make fmt-check
make validate
```

`make validate` runs `terraform init -backend=false` and `terraform validate` in every root. It does not plan or apply.

### One instance

```bash
cd simple_server
terraform init
terraform apply
terraform output app_url
./ssh_to_host.sh
```

The boot script installs Node before the page answers. Give it a few minutes, then open the URL. `./redeploy.sh` destroys and applies again, and Terraform asks you to confirm the destroy.

### Load balancer in one state

```bash
cd multiserver_loadbalancer
terraform init
terraform apply
terraform output app_url
```

Use the private key output the same way as the single-server stack (`terraform output -raw private_key`) if you want to SSH to an instance. `./test.sh` is only on the remote autoscaling root; here, curl the `app_url` output.

### Remote state

The store root creates the bucket its own backend would use, so the first apply is local. Bucket names are global. The examples use `react-calculator-remote-state` and `react-calculator-locks` from 2021. Pass a new `bucket_name` if that name is taken, and put the same name in each `backend.hcl`.

```bash
cd remote_state/remote_state_store
terraform init -backend=false
terraform apply
```

Copy `backend.hcl.example` to `backend.hcl` in the store root (and edit names if you changed them), then move the local state into the bucket:

```bash
terraform init -backend-config=backend.hcl -migrate-state
```

Create the launch template, then the autoscaling stack. In each directory, copy `backend.hcl.example` to `backend.hcl` first. The three example files use different state keys on purpose.

```bash
cd ../launch_config
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
terraform apply

cd ../autoscaling_loadbalancing
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
terraform apply
./test.sh
```

`remote_state_store` sets `prevent_destroy` on the bucket. `terraform destroy` will refuse to delete it until that lifecycle block is taken out of `s3.tf`. Empty the bucket before AWS will delete a versioned bucket.

The private key for instances launched this way is an output of `launch_config`, not of the autoscaling root. Instance IPs are the `public_ips` output on the autoscaling root, and that list stays empty until the instances exist.

## Notes from the 2026 refresh

The generations, resource names, open security groups, generated SSH key, and S3 plus DynamoDB locking are the original experiment. A few pieces had to move so the config matches current Terraform and AWS:

- Launch configurations are gone from these files. AWS accounts created on or after 1 October 2024 cannot create them. Both autoscaling examples use a launch template. `remote_state/launch_config/` keeps that directory name.
- The AMI is a current Ubuntu 24.04 lookup. The old id `ami-05ec0d2eeb9187f51` does not resolve, and SSH connects as `ubuntu` because that image's login user is `ubuntu`.
- `data.aws_subnet_ids` is now `data.aws_subnets`. S3 versioning, encryption, and a public-access block are separate resources. The archived `template_file` data source is gone; the boot script is a normal file.
- User data no longer runs `npm run dev` in the foreground, which kept cloud-init from finishing. systemd owns the process.
- Remote backends are partial. Bucket, key, region, and lock table live in a gitignored `backend.hcl`.

Security groups still allow SSH and the app port from `0.0.0.0/0`. That is a sandbox choice. Tear the stack down when you are finished, and keep state, `backend.hcl`, and `.pem` files out of git.
