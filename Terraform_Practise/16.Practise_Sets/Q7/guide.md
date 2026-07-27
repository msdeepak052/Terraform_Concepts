# Q7 — Use Workspaces for Environment Isolation

**Requirement:** Create `dev`, `staging`, and `prod` workspaces; use a different `.tfvars` file per workspace.

This guide is written to be worked through top-to-bottom: read the concept, understand the caveats *before* you touch AWS, then follow the hands-on steps using the scaffold already sitting in this folder (`providers.tf`, `variables.tf`, `locals.tf`, `terraform.tfvars`).

---

# 1. What is a Terraform Workspace?

A **workspace** is a named slot for **one state file**, under **one backend**, for **the same configuration**.

Normally, when you run `terraform init`, Terraform creates a single state file called `default`. Every `plan`/`apply` you run reads and writes that one state.

A workspace lets you keep **multiple, independent state files** for the exact same `.tf` code, and switch between them:

```
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

Now you have four workspaces: `default`, `dev`, `staging`, `prod` — each with its **own state file**, but all reading the **same `main.tf` / `variables.tf` / `providers.tf`**.

Inside your `.tf` files, Terraform exposes the active workspace as a read-only value:

```hcl
terraform.workspace   # -> "dev", "staging", "prod", or "default"
```

You use that value to make the *same code* behave differently per environment — e.g. tagging resources, naming S3 buckets, or picking instance sizes.

### How state is actually stored per workspace

| Backend | Where the state for a non-default workspace lives |
|---|---|
| **local** | `terraform.tfstate.d/<workspace_name>/terraform.tfstate` |
| **S3** (what this repo uses — see `providers.tf`) | `env:/<workspace_name>/<key>` inside the same bucket |

So with the backend already configured in [providers.tf](providers.tf):

```hcl
backend "s3" {
  bucket       = "terraform-practise-backend-deepak"
  region       = "ap-south-1"
  encrypt      = true
  use_lockfile = true
}
```

If you `init` with a key of `Q7/terraform.tfstate`, the resulting objects in S3 will look like:

```
s3://terraform-practise-backend-deepak/Q7/terraform.tfstate            <- default workspace
s3://terraform-practise-backend-deepak/env:/dev/Q7/terraform.tfstate   <- dev workspace
s3://terraform-practise-backend-deepak/env:/staging/Q7/terraform.tfstate
s3://terraform-practise-backend-deepak/env:/prod/Q7/terraform.tfstate
```

Terraform inserts the `env:/<workspace>/` prefix **automatically** — you never write it yourself.

---

# 2. Why is this required?

**Problem it solves:** you have one set of Terraform code (say, a VPC + EC2 web server) and you want to stand up a `dev`, `staging`, and `prod` copy of it, without:

- copy-pasting the entire folder three times (`Q7-dev/`, `Q7-staging/`, `Q7-prod/`), and
- manually keeping three copies of `main.tf` in sync every time you fix a bug or add a feature.

Workspaces give you **one codebase, N independent states**, so:

- `terraform plan` in `dev` only ever compares against `dev`'s resources — it has no idea `staging` or `prod` exist.
- You can safely experiment / destroy `dev` without any risk to `prod`'s state.
- Config drift-fixes and new features are written **once**, then rolled through each workspace with its own `.tfvars`.

This is the direct answer to the exam-style requirement: *"Create dev, staging, and prod workspaces; use different `.tfvars` files per workspace."* — workspaces isolate **state**, `.tfvars` files isolate **input values** (region, instance size, tags, counts). Together they let identical code produce three differently-sized, differently-tagged, independently-tracked environments.

---

# 3. Caveats — read this before you `apply` anything

This is the section most guides skip, and it's the part the certification exam (and real production usage) actually cares about.

### 3.1 Workspaces isolate **state**, not infrastructure boundaries
Switching to the `prod` workspace does **not** switch AWS accounts, IAM roles, regions, or credentials. All workspaces share:
- the same `provider "aws"` block (same credentials/profile, same `var.aws_region` unless your `.tfvars` overrides it),
- the same S3 bucket for state (just a different key prefix inside it).

If your AWS credentials in the shell have access to production resources, being in the `dev` workspace **does not protect you** — a bad `apply` can still hit real infra if your variables happen to point there. Workspaces are not a security or blast-radius boundary.

### 3.2 HashiCorp itself recommends against workspaces for prod/dev/staging separation at scale
From HashiCorp's own guidance: CLI workspaces are best for **short-lived, throwaway variations** (e.g. a feature branch's own sandbox), not for long-lived, meaningfully-different environments like prod vs. dev. The officially recommended pattern for real environment isolation is **separate root configurations / directories per environment** (or separate Terraform Cloud workspaces, which *are* fully isolated — different variables, different run history, different access controls).

**Why this matters for you:** this Q7 exercise is the *textbook/exam* version (and a legitimate way to learn the mechanics), but don't reach for CLI workspaces as your default "prod vs dev" strategy in a real company. Use them here to learn `terraform.workspace`, per-workspace state, and `-var-file` switching — then know that `envs/dev/`, `envs/staging/`, `envs/prod/` directories (each with their own backend key) is the safer real-world pattern for anything long-lived.

### 3.3 No built-in link between a workspace and a `.tfvars` file
Terraform does **not** auto-select `dev.tfvars` because you're in the `dev` workspace. That mapping is entirely manual — you must remember to pass the matching file:

```bash
terraform workspace select dev
terraform plan -var-file="dev.tfvars"      # <- your responsibility to match these up
```

If you run `terraform workspace select prod` but forget to pass `-var-file="prod.tfvars"` (or pass `dev.tfvars` by mistake), Terraform will happily plan `prod`'s state using `dev`'s variables. This is the single most common workspace mistake — always double-check `terraform workspace show` *and* the `-var-file` flag together before applying.

### 3.4 `terraform workspace delete` has a safety guard — but only one
Terraform refuses to delete a workspace that still has resources tracked in its state (non-empty state), unless you force it with `-force`. This protects you from silently orphaning real infrastructure — but `-force` will happily discard the state pointer anyway, so never use it without first confirming the workspace's resources have actually been destroyed.

### 3.5 You cannot delete the workspace you're currently in
You must `terraform workspace select` back to `default` (or another workspace) before you can delete `dev`/`staging`/`prod`.

### 3.6 Backend configuration itself is shared across all workspaces
The `backend "s3" { bucket = ... }` block in [providers.tf](providers.tf) applies to **every** workspace equally. You cannot point `prod` at a different S3 bucket than `dev` using workspaces alone — if you need genuinely separate backends (e.g. a separate prod state bucket with stricter IAM/versioning), that's another point in favor of separate directories over workspaces.

### 3.7 `default` workspace is special and easy to forget about
It always exists, can't be deleted, and if you never explicitly created/selected another workspace, you're silently working in it. Get in the habit of running `terraform workspace show` before every plan/apply during this exercise.

---

# 4. Hands-on Demo — Step by Step

We'll build directly on top of what's already in this folder.

### Current starting point

- [providers.tf](providers.tf) — AWS provider + S3 backend (no `key` set yet — you'll supply it at `init` time)
- [variables.tf](variables.tf) — just `aws_region` so far
- [locals.tf](locals.tf) — `common_tags` (`Environment = "Dev"`, `Owner = "Platform-Team"`) — hardcoded, we'll fix this to derive from the workspace
- [terraform.tfvars](terraform.tfvars) — `aws_region = "ap-south-1"`
- No `main.tf` yet — we'll add one small resource so you can actually *see* the per-workspace difference in `plan`.

## Step 1 — Initialize with an explicit state key

The S3 backend requires a `key` (the path/filename for the state object inside the bucket). Supply it at init time so this exercise's state doesn't collide with Q1–Q6:

```bash
cd Q7
terraform init -reconfigure -backend-config="key=Terraform_Practise/16.Practise_Sets/Q7" 
```

## Step 2 — Confirm you're in `default`

```bash
terraform workspace show
# -> default
```

## Step 3 — Create the three workspaces

```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

Each `new` command **also switches you into it immediately**. After running all three, list them:

```bash
terraform workspace list
```

```
  default
  dev
  staging
* prod        <- '*' marks the currently active workspace
```

Switch back to `dev` to continue the exercise in order:

```bash
terraform workspace select dev
```

## Step 4 — Add environment-specific variables

Add these to [variables.tf](variables.tf) (append, don't replace what's there):

```hcl
variable "instance_type" {
  description = "EC2 instance size for this environment"
  type        = string
}

variable "instance_count" {
  description = "Number of instances for this environment"
  type        = number
  default     = 1
}
```

## Step 5 — Create one `.tfvars` file per environment

Create three new files in this folder (do **not** overwrite `terraform.tfvars` — keep that as your `default`-workspace fallback).

**`dev.tfvars`**
```hcl
aws_region     = "ap-south-1"
instance_type  = "t2.micro"
instance_count = 1
```

**`staging.tfvars`**
```hcl
aws_region     = "ap-south-1"
instance_type  = "t2.small"
instance_count = 1
```

**`prod.tfvars`**
```hcl
aws_region     = "ap-south-1"
instance_type  = "t3.medium"
instance_count = 2
```

This is deliberately simple (instance size + count) so the *difference between environments* is easy to see in `terraform plan` output — in a real exercise you'd also vary things like CIDR ranges, AMI, or enabling/disabling monitoring per tier.

## Step 6 — Make tags derive from the workspace automatically

Update [locals.tf](locals.tf) so `Environment` is no longer hardcoded to `"Dev"` — it should reflect whichever workspace is currently active:

```hcl
locals {
  common_tags = {
    Environment = terraform.workspace
    Owner       = "Platform-Team"
  }
}
```

Now the **same code**, run in three different workspaces, tags resources `Environment = "dev"`, `"staging"`, or `"prod"` with zero manual editing.

## Step 7 — Add a minimal resource so you can see it in action

Create `main.tf`:

```hcl
resource "aws_instance" "app" {
  count         = var.instance_count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  tags = merge(
    local.common_tags,
    {
      Name = "q7-${terraform.workspace}-app-${count.index + 1}"
    }
  )
}
```

And `data.tf` (a lookup so you don't have to hardcode an AMI ID):

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
```

> Note: this intentionally omits `subnet_id`/`vpc_security_group_ids` to keep the exercise focused purely on workspaces. If you want it to actually `apply` successfully, reuse the VPC/SG modules from Q6, or add `subnet_id = data.aws_subnet.default.id` pointing at your account's default VPC subnet.

## Step 8 — Plan each workspace with its matching `.tfvars`

```bash
terraform workspace select dev
terraform plan -var-file="dev.tfvars"
```

Look at the plan output: resource name will be `q7-dev-app-1`, `instance_type = "t2.micro"`, tag `Environment = "dev"`.

```bash
terraform workspace select staging
terraform plan -var-file="staging.tfvars"
```

Now: `q7-staging-app-1`, `instance_type = "t2.small"`, tag `Environment = "staging"`. Terraform shows this as a **fresh create** — it has no knowledge of `dev`'s resource, because it's reading `staging`'s own (empty) state file.

```bash
terraform workspace select prod
terraform plan -var-file="prod.tfvars"
```

Now: **two** instances (`q7-prod-app-1`, `q7-prod-app-2`), `instance_type = "t3.medium"`, tag `Environment = "prod"`.

## Step 9 — (Optional) Apply, then verify isolation for real

If you want to actually provision (mind AWS costs — destroy afterward):

```bash
terraform workspace select dev
terraform apply -var-file="dev.tfvars"
```

Then check the state file location in S3:

```bash
aws s3 ls s3://terraform-practise-backend-deepak/env:/dev/Q7/
```

Repeat for `staging` and `prod` — you'll see three separate state objects, three separate sets of tracked resources, from one codebase.

## Step 10 — Clean up

Destroy resources **in every workspace you applied**, using that workspace's own `.tfvars`, before deleting the workspace:

```bash
terraform workspace select dev
terraform destroy -var-file="dev.tfvars"

terraform workspace select staging
terraform destroy -var-file="staging.tfvars"

terraform workspace select prod
terraform destroy -var-file="prod.tfvars"
```

Then remove the workspaces (you must be *outside* a workspace to delete it):

```bash
terraform workspace select default
terraform workspace delete dev
terraform workspace delete staging
terraform workspace delete prod
```

If any `delete` is rejected, it means that workspace's state isn't empty — go back and `destroy` it first (this is the safety guard from §3.4 doing its job).

---

# 5. Command Cheat Sheet

| Command | Purpose |
|---|---|
| `terraform workspace show` | Print the currently active workspace |
| `terraform workspace list` | List all workspaces (`*` marks active one) |
| `terraform workspace new <name>` | Create a workspace and switch to it |
| `terraform workspace select <name>` | Switch to an existing workspace |
| `terraform workspace delete <name>` | Delete an empty (no-resources) workspace |
| `terraform plan -var-file="<env>.tfvars"` | Plan using that environment's variable values |
| `terraform.workspace` (in `.tf` code) | Read-only reference to the active workspace's name |

---

# 6. Key Takeaway

- **Workspace** = which **state file** you're pointed at (same code, isolated state).
- **`-var-file`** = which **input values** you're using (region, size, count, tags).
- You must keep both in sync **yourself** — Terraform will not stop you from mixing `prod` workspace with `dev.tfvars`.
- Great for learning and short-lived variations; for real, long-lived prod/dev/staging separation, most teams move to separate root configs/directories (or Terraform Cloud workspaces) instead — see §3.2.
