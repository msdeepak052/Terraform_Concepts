# Terraform Practice Questions — Beginner to Real-World (with Answers + Industry Best Practices)

This file is the dedicated practice-question bank for the course, organized Beginner → Intermediate → Advanced → Module-Focused → Real-World Industry Scenarios. Every question keeps the original working answer where one was already provided in your exercise material (cleaned up and explained), and every question adds an **Industry Best-Practice Notes** box — what a senior engineer would additionally do in a real production environment, and why the "textbook-correct" answer is sometimes not the "production-correct" answer.

**How to use this file:** Don't just read the answers. Attempt each question yourself first — write your own `.tf` files, run `terraform plan`, and only then compare against the answer here. The certification exam tests whether you can *recognize which feature solves a given scenario*, not whether you can recite code from memory.

AWS-only throughout. All code is illustrative — replace AMI IDs, VPC IDs, and CIDR ranges with values from your own account before running anything for real.

---

## Table of Contents
1. [Beginner-Level Scenarios (7)](#beginner-level-scenarios)
   1. [Provision a Single EC2 Instance](#1-provision-a-single-ec2-instance)
   2. [Create a VPC with a Public Subnet](#2-create-a-vpc-with-a-public-subnet)
   3. [Use Input Variables](#3-use-input-variables)
   4. [Define and Use Output Variables](#4-define-and-use-output-variables)
   5. [Create a Simple Security Group](#5-create-a-simple-security-group)
   6. [Destroy Specific Resources](#6-destroy-specific-resources)
   7. [Terraform Formatting and Validation](#7-terraform-formatting-and-validation)
2. [Intermediate-Level Scenarios (10)](#intermediate-level-scenarios)
   1. [Create a Reusable VPC Module](#1-create-a-reusable-vpc-module)
   2. [Deploy EC2 Instances in a Private Subnet with a NAT Gateway](#2-deploy-ec2-instances-in-a-private-subnet-with-a-nat-gateway)
   3. [Use Remote State with S3 and DynamoDB](#3-use-remote-state-with-s3-and-dynamodb-and-the-modern-s3-native-locking-alternative)
   4. [Use Workspaces for Environment Isolation](#4-use-workspaces-for-environment-isolation)
   5. [Conditionally Create Resources](#5-conditionally-create-resources)
   6. [Use Data Sources to Reference AMIs](#6-use-data-sources-to-reference-amis)
   7. [Pass Variables Using `terraform.tfvars`](#7-pass-variables-using-terraformtfvars)
   8. [Define Multiple Security Groups Dynamically](#8-define-multiple-security-groups-dynamically)
   9. [Import Existing Resources](#9-import-existing-resources)
   10. [Provision Multiple EC2 Instances Using `for_each`](#10-provision-multiple-ec2-instances-using-for_each)
3. [Advanced-Level Scenarios (10)](#advanced-level-scenarios)
   1. [Build a Multi-Tier Architecture Using Modules](#1-build-a-multi-tier-architecture-using-modules)
   2. [Use Dynamic Blocks for Security Group Rules](#2-use-dynamic-blocks-for-security-group-rules)
   3. [Split Configuration into Multiple Files and Environments](#3-split-configuration-into-multiple-files-and-environments)
   4. [Terraform CI/CD Integration (GitHub Actions / GitLab CI)](#4-terraform-cicd-integration-github-actions--gitlab-ci)
   5. [Use `locals` and Complex Data Structures](#5-use-locals-and-complex-data-structures)
   6. [Create and Manage an EKS Cluster](#6-create-and-manage-an-eks-cluster)
   7. [Use a Remote Module from GitHub](#7-use-a-remote-module-from-github)
   8. [Terraform State Management: Move/Remove Resources](#8-terraform-state-management-moveremove-resources)
   9. [Handle Resource Dependencies with `depends_on`](#9-handle-resource-dependencies-with-depends_on)
   10. [Multiple AWS Profiles/Regions](#10-multiple-aws-profilesregions)
4. [Module-Focused Practice (10)](#module-focused-practice)
   1. [Module for EC2 with Custom Security Group](#1-module-for-ec2-with-custom-security-group)
   2. [Nested Module Usage](#2-nested-module-usage)
   3. [Parameterize Resource Count in a Module](#3-parameterize-resource-count-in-a-module)
   4. [Write a Module for S3 Bucket Creation](#4-write-a-module-for-s3-bucket-creation)
   5. [Module with Conditional Logic](#5-module-with-conditional-logic)
   6. [Module for CloudWatch Alarms](#6-module-for-cloudwatch-alarms)
   7. [DRY Modules for Multi-Tier Architecture](#7-dry-modules-for-multi-tier-architecture)
   8. [Use of `locals` in Modules](#8-use-of-locals-in-modules)
   9. [Output Propagation from Modules](#9-output-propagation-from-modules)
   10. [Use Public Modules (Terraform Registry or GitHub)](#10-use-public-modules-terraform-registry-or-github)
5. [Real-World Industry Scenarios (20)](#real-world-industry-scenarios)
   1. [Launch a Scalable Web Application](#1-launch-a-scalable-web-application)
   2. [Deploy a Multi-Tier Architecture](#2-deploy-a-multi-tier-architecture)
   3. [Set Up Terraform CI/CD in GitHub Actions](#3-set-up-terraform-cicd-in-github-actions)
   4. [Terraform with Remote State in S3 and State Locking in DynamoDB](#4-terraform-with-remote-state-in-s3-and-state-locking-in-dynamodb)
   5. [Manage IAM Roles and Policies](#5-manage-iam-roles-and-policies)
   6. [Provision an EKS Cluster with Worker Nodes](#6-provision-an-eks-cluster-with-worker-nodes)
   7. [Deploy a Serverless Application Using Lambda and API Gateway](#7-deploy-a-serverless-application-using-lambda-and-api-gateway)
   8. [Blue/Green Deployment Using Terraform Workspaces](#8-bluegreen-deployment-using-terraform-workspaces)
   9. [Provision a Multi-Region Disaster Recovery Setup](#9-provision-a-multi-region-disaster-recovery-setup)
   10. [Infrastructure Tagging Strategy](#10-infrastructure-tagging-strategy)
   11. [Manage Secrets with AWS SSM or Secrets Manager](#11-manage-secrets-with-aws-ssm-or-secrets-manager)
   12. [Scheduled Auto Start/Stop of EC2 Instances](#12-scheduled-auto-startstop-of-ec2-instances)
   13. [Monitor Infrastructure with CloudWatch Dashboards](#13-monitor-infrastructure-with-cloudwatch-dashboards)
   14. [Use Sentinel or OPA for Policy-as-Code](#14-use-sentinel-or-opa-for-policy-as-code)
   15. [Automate SSL Certificate Management](#15-automate-ssl-certificate-management)
   16. [Use Terraform to Provision Azure/AWS Hybrid Infrastructure](#16-use-terraform-to-provision-azureaws-hybrid-infrastructure)
   17. [Import Legacy Resources to Terraform](#17-import-legacy-resources-to-terraform)
   18. [Create an Audit-Ready Logging and Monitoring Setup](#18-create-an-audit-ready-logging-and-monitoring-setup)
   19. [Onboard New Environments with a Single Command](#19-onboard-new-environments-with-a-single-command)
   20. [Implement Cost Optimization with Auto Scaling and Spot Instances](#20-implement-cost-optimization-with-auto-scaling-and-spot-instances)

---

## Beginner-Level Scenarios

### 1. Provision a Single EC2 Instance
**Requirement:** Launch one EC2 instance in AWS, using variables for AMI ID, instance type, and tags.

**Straightforward answer** (this is the actual scope of the question — a beginner should be able to write exactly this without any of the randomization tricks below):

```hcl
# variables.tf
variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name"
}

# main.tf
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "MyEC2Instance"
  }
}

# terraform.tfvars
aws_region    = "ap-south-1"
ami_id        = "ami-0e35ddab05955cf57"
instance_type = "t3.micro"
key_name      = "lappynewawss"
```

**Enrichment — the "random AZ + fun name" pattern (from the original exercise set, useful for demos/sandboxes):**
Two small utility resources from the `random` provider are genuinely useful for sandbox/demo work — `random_shuffle` and `random_pet`.

```hcl
# random_shuffle — picks random element(s) from a list. Useful for spreading
# demo resources across AZs without hardcoding one.
data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "az" {
  input        = data.aws_availability_zones.available.names
  result_count = 1
}

# random_pet — generates a human-readable random name (e.g. "happy-tiger").
# Useful for globally-unique names (S3 buckets) or memorable demo tags.
resource "random_pet" "ec2_name" {
  length    = 2
  separator = "-"
}

resource "aws_instance" "example" {
  ami                = var.ami_id
  instance_type      = var.instance_type
  availability_zone  = random_shuffle.az.result[0]

  tags = {
    Name = random_pet.ec2_name.id
  }
}
```
`random_shuffle.az.result[0]` picks one AZ out of the shuffled list (e.g. `"ap-south-1b"`); `random_pet.ec2_name.id` produces something like `"happy-koala"`. Combined with a `data "aws_subnets"` lookup filtered to that AZ, you get an EC2 instance that lands in a random AZ with a random, readable name — handy for repeatable demo/test environments where you don't want naming collisions.

> **Industry Best-Practice Notes**
> - **Never hardcode an AMI ID** the way `terraform.tfvars` does above (`ami-0e35ddab05955cf57`). AMI IDs are region-specific and go stale (deregistered, or simply out of date with security patches) — the production pattern is `data "aws_ami"` filtering on `most_recent = true` and an owner/name pattern (see Beginner Q6 below and Domain 2 notes). Hardcoding is acceptable only in a one-off learning exercise.
> - **Don't put a real key pair name in version-controlled `.tfvars`.** In production, EC2 access is provisioned via **AWS Systems Manager Session Manager** (no SSH key, no open port 22, full IAM-audited session logging) rather than `key_name` + a static keypair. Reserve `key_name` for genuinely air-gapped/legacy scenarios.
> - **Always set explicit tags** beyond just `Name` — at minimum `Environment`, `Owner`, `CostCenter` — because untagged resources are the #1 cause of "who owns this and can we delete it" incidents during AWS cost audits. See Real-World Scenario 10 below.
> - `random_pet`/`random_shuffle` are fine for demos but should never substitute for deliberate, deterministic naming/placement in real environments — production subnet/AZ placement should be an explicit design decision (e.g., one instance per AZ for HA), not random.

---

### 2. Create a VPC with a Public Subnet
**Requirement:** Define a VPC with CIDR block `10.0.0.0/16`; add a public subnet, an internet gateway, and a route table.

```hcl
# variables.tf
variable "aws_region"  { type = string }
variable "cidr_block"  { type = string }

variable "subnets" {
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  description = "List of subnets to create"
}

# main.tf
provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = { Name = "main-vpc" }
}

resource "aws_subnet" "public_subnet" {
  for_each = { for s in var.subnets : s.name => s }

  vpc_id                  = aws_vpc.main.id
  cidr_block               = each.value.cidr
  availability_zone        = each.value.az
  map_public_ip_on_launch  = can(regex("public", each.key))

  tags = { Name = each.key }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = { for s in var.subnets : s.name => s if can(regex("public", s.name)) }

  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public_rt.id
}

# terraform.tfvars
aws_region = "ap-south-1"
cidr_block = "10.0.0.0/16"
subnets = [
  { name = "subnet-public-1", cidr = "10.0.1.0/24", az = "ap-south-1a" },
  { name = "subnet-public-2", cidr = "10.0.2.0/24", az = "ap-south-1b" },
]

# outputs.tf
output "vpc_id"  { value = aws_vpc.main.id }
output "igw_id"  { value = aws_internet_gateway.igw.id }
output "public_subnet_ids" {
  value = [for name, s in aws_subnet.public_subnet : s.id if can(regex("public", name))]
}
```

`for_each` (rather than `count`) is used deliberately here — each subnet is keyed by its `name`, so adding/removing a subnet from the middle of the list doesn't force Terraform to destroy and recreate unrelated subnets (see Domain 4b notes for the full count-vs-for_each failure mode this avoids).

> **Industry Best-Practice Notes**
> - A VPC with **only a public subnet** is a red flag in a real review — anything that touches a database or internal service belongs in a private subnet with no direct route to the internet gateway. Treat this exercise as step one of Intermediate Q2 (private subnet + NAT), not a finished design.
> - **`can(regex("public", each.key))`** is a clever trick for a demo, but it's fragile — a subnet named `"public-facing-lb"` matches, but a typo like `"pblic-1"` silently doesn't, with no error. In production, prefer an explicit `type = "public"` or `"private"` field on the subnet object instead of pattern-matching a name string.
> - Real VPC modules (e.g. the official `terraform-aws-modules/vpc/aws` registry module) also configure **VPC Flow Logs** and **default security group lockdown** (AWS creates a permissive default SG per VPC that should always be restricted to no rules) — both frequently missed in hand-rolled VPC code.

---

### 3. Use Input Variables
**Requirement:** Parameterize values like VPC name, CIDR, and subnet CIDR.

This is already demonstrated throughout Q1 and Q2 above — every hardcoded value (`region`, `cidr_block`, AMI, instance type, subnet list) is exposed as a `variable` block with a `type` and `description`, and supplied via `terraform.tfvars` rather than being written directly into `resource` blocks.

> **Industry Best-Practice Notes**
> - Every variable should have a `description` (as shown) — a variable with no description is a support burden for the next engineer who has to guess its purpose from the name alone.
> - Add `validation` blocks on variables that have a constrained valid range (e.g., `instance_type` must match `^[a-z0-9]+\.[a-z0-9]+$`, `cidr_block` must be a valid CIDR via `can(cidrhost(var.cidr_block, 0))`) — see Domain 4c notes for the full pattern. A bad CIDR should fail at `terraform plan`, not halfway through `apply`.

---

### 4. Define and Use Output Variables
**Requirement:** Output the instance ID and public IP of the EC2 instance.

```hcl
# outputs.tf
output "instance_id" {
  value = aws_instance.example.id
}

output "instance_public_ip" {
  value = aws_instance.example.public_ip
}
```
Sample output after `terraform apply`:
```
Outputs:
instance_id        = "i-0b2f3397b10417de0"
instance_public_ip = "13.201.22.20"
```

> **Industry Best-Practice Notes**
> - If the output ever touches something sensitive (a DB password, a generated secret), mark it `sensitive = true` — this only masks console/CLI display, it does **not** encrypt the value inside the state file (see Domain 4c's Sensitive Data section; for genuine state-file protection you need `ephemeral`/write-only arguments or a secrets manager).
> - Outputs are the **contract** a module or root config exposes to whatever consumes it (a human, a CI pipeline, or another Terraform config via `terraform_remote_state`). Treat renaming or removing an output as a breaking change requiring a version bump if the module is shared — don't rename outputs casually once other teams depend on them.

---

### 5. Create a Simple Security Group
**Requirement:** Allow SSH (port 22) and HTTP (port 80) from any IP.

```hcl
resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = data.aws_vpc.selected.id
  tags   = { Name = "web-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "custom_ingress" {
  for_each = { for r in var.ingress_rules : "${r.from_port}-${r.to_port}-${r.cidr}" => r }

  security_group_id = aws_security_group.web_sg.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr
  description       = each.value.description
}

resource "aws_vpc_security_group_egress_rule" "custom_egress" {
  for_each = { for r in var.egress_rules : "${r.protocol}-${r.cidr}" => r }

  security_group_id = aws_security_group.web_sg.id
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr
  description       = each.value.description
}
```
```hcl
# terraform.tfvars
ingress_rules = [
  { from_port = 22, to_port = 22, protocol = "tcp", cidr = "10.0.0.0/16", description = "SSH access" },
  { from_port = 80, to_port = 80, protocol = "tcp", cidr = "0.0.0.0/0",   description = "HTTP access" },
]
egress_rules = [
  { protocol = "-1", cidr = "0.0.0.0/0", description = "Allow all outbound traffic" },
]
```
Note this uses the modern, per-rule `aws_vpc_security_group_ingress_rule` / `_egress_rule` resources (introduced to replace inline `ingress {}` / `egress {}` blocks) — each rule is its own resource, which is exactly what lets `for_each` add/remove individual rules without touching the others.

> **Industry Best-Practice Notes**
> - The question literally asks for SSH open "from any IP" — **never do this in a real environment.** In the sample `.tfvars` above, SSH is deliberately restricted to `10.0.0.0/16` (the VPC's own CIDR) rather than `0.0.0.0/0`; only HTTP (meant to be public-facing) uses `0.0.0.0/0`. If your real requirement really is "SSH reachable from the whole internet," that itself is the finding a security review would flag — use a **bastion host**, **AWS Systems Manager Session Manager**, or a VPN/Client VPN endpoint instead of a world-open port 22.
> - `description` on every rule (as shown) is a small habit that pays off enormously during a security audit six months later, when nobody remembers why a rule exists.
> - Use dedicated security groups per tier (web/app/db) that reference **each other by security-group ID** (`aws_security_group.app_sg.id` as the source, not a CIDR) rather than one flat security group for everything — this is the standard "security-group chaining" pattern for multi-tier architectures (see Real-World Scenario 2).

---

### 6. Destroy Specific Resources
**Requirement:** Use `terraform destroy -target=aws_instance.example` to destroy the EC2 instance only.

```hcl
resource "aws_instance" "ec2" {
  count             = 3
  ami               = var.ami_id
  instance_type     = var.instance_type
  availability_zone = random_shuffle.az.result[0]
  key_name          = var.key_name
  subnet_id         = local.subnets_in_random_az[0]

  tags = merge(local.tags, { Name = "ec2-instance-${count.index + 1}" })
}
```
```
$ terraform destroy -target=aws_instance.ec2[1]
```
`terraform state list` before the targeted destroy shows all three instances (`aws_instance.ec2[0]`, `[1]`, `[2]`) plus supporting data sources; after the targeted destroy, only index `[1]` is gone from state and from AWS — the other two, and the shared VPC/subnet/security-group resources, are untouched.

> **Industry Best-Practice Notes**
> - `-target` is explicitly documented by HashiCorp as an **escape hatch for exceptional situations** (recovering from a broken apply, surgically removing one broken resource) — not a routine workflow tool. Habitual use of `-target` is a sign your configuration should be split into smaller, independently-applied root modules/workspaces instead.
> - Because this example uses `count`, destroying `ec2[1]` (the *middle* instance) and later re-adding a replacement will shift indices and can force unrelated instances to be destroyed/recreated on the next `apply` — the classic count pitfall (Domain 4b). If instances are meant to be independently destroyable by identity, use `for_each` keyed by a stable name instead of `count`.
> - Prefer expressing "I want to remove exactly this resource from config *and* real infrastructure" by deleting it from `.tf` and running a normal `terraform apply` (which computes the same destroy safely, with a full plan showing everything else is unaffected) over reaching for `-target` as a first resort.

---

### 7. Terraform Formatting and Validation
**Requirement:** Run `terraform fmt`, `terraform validate`, and `terraform plan` as part of the workflow.

```bash
terraform fmt        # rewrites files to canonical style (indentation, alignment, quoting)
terraform validate    # checks internal syntax/type consistency — no AWS calls, no credentials needed
terraform plan        # calls the AWS API, compares real state vs config, shows the proposed diff
```

> **Industry Best-Practice Notes**
> - Run this exact three-command sequence — `fmt`, `validate`, `plan` — as the **first stage of every CI pipeline**, before any `apply` stage, and fail the pipeline if `terraform fmt -check` reports unformatted files or `validate` errors. This catches the majority of trivial mistakes (typos, missing required arguments, malformed HCL) before they ever reach a real `plan` against AWS.
> - Remember what `validate` does **not** catch: it has zero AWS awareness. A `subnet_id` that references a subnet which doesn't exist in your VPC will pass `validate` cleanly and only fail at `apply` time (or show up as an error during `plan` once Terraform tries to read live data). Don't mistake "validate passed" for "this will actually work."

---

## Intermediate-Level Scenarios

### 1. Create a Reusable VPC Module
**Requirement:** Build a module for VPC creation; accept variables for CIDR blocks, subnet count, etc.

```
modules/vpc/
├── main.tf        # aws_vpc, aws_subnet (for_each), aws_internet_gateway,
│                  # aws_route_table + association, aws_security_group + rules
├── variables.tf   # cidr_block, vpc_name, subnets (list of objects), tags,
│                  # ingress_rules, egress_rules, route CIDRs
└── outputs.tf     # vpc_id, subnets (full object, so callers can pull .id, .cidr_block, etc.)
```
Root module call:
```hcl
module "vpc" {
  source      = "./modules/vpc"
  cidr_block  = var.cidr_block
  subnets     = var.subnets
  vpc_name    = var.vpc_name
  tags        = local.common_tags
}

output "vpc_id"  { value = module.vpc.vpc_id }
output "subnets" { value = module.vpc.subnets }
```
The module's own `variables.tf` defines every input it needs (`cidr_block`, `subnets`, `tags`, route CIDRs, ingress/egress rule lists) with no defaults for anything the caller must decide — this forces every consumer to make an explicit choice rather than silently inheriting a default that might not fit their environment.

> **Industry Best-Practice Notes**
> - A module that will be reused across **multiple teams or repos** should be version-pinned when called (`source = "git::https://github.com/org/tf-modules.git//vpc?ref=v1.4.0"` or a Registry version constraint) — never `ref=main`, which lets an unreviewed change in the module silently alter every consumer's next `plan`.
> - Publish a `README.md` (or run `terraform-docs` to auto-generate one) listing every input/output — this is also a **hard requirement** for publishing to the public Terraform Registry (Domain 5 notes).
> - Notice the module outputs the **full subnet object map**, not just IDs — this lets calling code destructure whatever attribute it needs (`.cidr_block`, `.availability_zone`) without you having to add a new output every time a caller needs one more field.

---

### 2. Deploy EC2 Instances in a Private Subnet with a NAT Gateway
**Requirement:** Create a private subnet and a NAT Gateway in a public subnet; launch EC2 instances with internet access via the NAT.

```
EC2-PVT-NAT/
├── main.tf, variables.tf, outputs.tf, terraform.tfvars, locals.tf
└── modules/
    ├── vpc/   → VPC, public+private subnets, IGW, NAT + EIP, both route tables, security group
    └── ec2/   → the EC2 instance itself
```
Key NAT Gateway piece (inside `modules/vpc/main.tf`):
```hcl
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  # NAT must live in a PUBLIC subnet even though it serves PRIVATE subnets
  subnet_id = element(
    [for s in aws_subnet.subnets : s.id if can(regex("public", s.tags["Name"]))],
    0
  )
  allocation_id = aws_eip.nat_eip.id

  # Explicit dependency: NAT creation fails if the IGW isn't attached yet,
  # and Terraform can't infer this ordering from an attribute reference alone.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = var.pvt_destination_route_cidr   # "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}
```
Root module then wires EC2 instances into the *private* subnets only, using the VPC module's private subnet IDs as input to an `ec2` module call with `for_each`:
```hcl
module "ec2_private" {
  source   = "./modules/ec2"
  for_each = module.vpc.private_subnet_ids

  subnet_id = each.value
  ec2_sg    = [module.vpc.sg_id]
  tags      = merge(local.common_tags, { Name = "web-server-${each.key}" })
}
```

> **Industry Best-Practice Notes**
> - This is precisely why the `depends_on` on the NAT Gateway matters: AWS will accept the NAT Gateway creation call even before the internet gateway is fully attached, but the NAT will then be non-functional until it is — a classic case where Terraform's automatic dependency graph (built from attribute references) doesn't capture a *runtime* ordering requirement, so an explicit `depends_on` is the correct, deliberate override (Domain 4c notes).
> - **One NAT Gateway per AZ** (not one shared NAT for the whole VPC) is the production-grade pattern — a single NAT Gateway is a single point of failure for every private subnet's outbound internet access if that AZ has an issue. The exercise above uses one NAT for simplicity/cost; scale it to per-AZ NAT Gateways for a real multi-AZ workload.
> - NAT Gateways bill **per hour plus per GB processed** — for a pure "occasionally patch instances" use case at small scale, a self-managed **NAT instance** or **VPC endpoints** (for AWS-service traffic like S3/ECR, which don't need to leave the AWS network at all) can be considerably cheaper. Always check the cost model against actual egress volume.

---

### 3. Use Remote State with S3 and DynamoDB (and the modern S3-native-locking alternative)
**Requirement:** Store Terraform state in S3; use DynamoDB for state locking.

**Traditional pattern (any Terraform version):**
```hcl
resource "aws_s3_bucket" "tf_state" {
  bucket = "deepak-terraform-state"
}
resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_dynamodb_table" "tf_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
```
```hcl
terraform {
  backend "s3" {
    bucket         = "deepak-terraform-state"
    key            = "vpc/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```
Verification: concurrent `terraform apply` in a second terminal while the first is mid-apply fails fast with `Error acquiring the state lock` — confirming DynamoDB is doing its job.

**Modern alternative (Terraform 1.10+): S3-native locking, no DynamoDB table needed**
```hcl
terraform {
  backend "s3" {
    bucket       = "deepak-terraform-state"
    key          = "vpc/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true   # native S3 conditional-write locking — replaces dynamodb_table
  }
}
```
Concurrent applies now fail with `Error: State file is locked by another operation`, backed by a temporary `.tfstate.lockfile` object in S3 instead of a DynamoDB row.

| | Old: S3 + DynamoDB | New: S3 native lock |
|---|---|---|
| Terraform version required | any | **1.10+** |
| IAM permissions needed | S3 + DynamoDB | S3 only |
| Extra AWS resource to manage | DynamoDB table | none |
| Monthly cost | small DynamoDB charge | S3 only |

> **Industry Best-Practice Notes**
> - If your organization is already on Terraform ≥ 1.10, **prefer `use_lockfile = true` over standing up a DynamoDB table** for new backends — one fewer resource to secure, back up, and pay for. Existing DynamoDB-locked backends don't need urgent migration; there's no functional downside to leaving them as-is.
> - Always enable **S3 bucket versioning** on the state bucket (shown above) regardless of which locking method you use — it's your only recovery path if a bad `apply` or an accidental `terraform state rm` corrupts the state file; you can restore the previous object version.
> - Enable **S3 default encryption** (SSE-S3 or SSE-KMS) on the state bucket itself, in addition to the backend's `encrypt = true` — `encrypt` controls encryption of the state *in transit/at the backend API level*, but the bucket's own default encryption setting is what protects data at rest if someone directly lists the bucket's objects outside of Terraform.
> - Never grant the CI role broader S3 permissions than `s3:GetObject`/`PutObject`/`ListBucket` scoped to the exact state key prefix it needs — a compromised CI credential with full bucket access can read every environment's state (and every plaintext secret sitting in it).

---

### 4. Use Workspaces for Environment Isolation
**Requirement:** Create `dev`, `staging`, and `prod` workspaces; use different `.tfvars` files per workspace.

```hcl
terraform {
  backend "s3" {
    bucket = "deepak-terraform-state"
    key    = "workspace-demo/terraform.tfstate"
    region = "ap-south-1"
  }
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "${var.env_name}-workspace-demo-${random_id.suffix.hex}"
  tags   = { Environment = var.env_name }
}
resource "random_id" "suffix" { byte_length = 2 }
```
```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
terraform workspace list
#   default
# * dev
#   staging
#   prod

terraform workspace select dev
terraform apply -var-file="dev.tfvars" -auto-approve
# state → s3://.../workspace-demo/env:/dev/terraform.tfstate

terraform workspace select prod
terraform apply -var-file="prod.tfvars" -auto-approve
# state → s3://.../workspace-demo/env:/prod/terraform.tfstate
```
Each workspace gets its own state file path automatically (`env:/<workspace-name>/...` under the same S3 key prefix) — same backend config, same `.tf` code, three completely isolated state files and three separate sets of real AWS resources.

> **Industry Best-Practice Notes**
> - Remember the explicit caveat from Domain 6: CLI **Terraform Workspaces only isolate *state*** — they do not isolate variable values, provider credentials, or (critically) which AWS account/region you're pointed at unless your own `.tfvars`/CI logic keys off `terraform.workspace` correctly. It is entirely possible to `terraform workspace select prod` and then, due to a `.tfvars` mistake, apply prod-sized changes to what you believe is dev. HCP Terraform's *workspace* concept (a completely separate config+state+variables+run-history entity) is the safer isolation boundary for genuinely critical environments like production.
> - A very common production pattern instead of (or in addition to) CLI workspaces is **directory-per-environment** (`envs/dev/`, `envs/staging/`, `envs/prod/`, each with its own backend key and `.tfvars`, calling shared modules) — it trades a little duplication for the guarantee that you cannot `apply` to the wrong environment by forgetting a `workspace select`. Terragrunt (files 13-15) automates this directory-per-environment pattern without the duplication cost.
> - Never let `default` be a real environment — if `terraform workspace list` shows resources under `default`, that's usually a sign someone ran `apply` before creating/selecting the intended workspace.

---

### 5. Conditionally Create Resources
**Requirement:** Use `count` or `for_each` to create a resource only under certain conditions.

```hcl
variable "create_nat_gateway" {
  type    = bool
  default = true
}

# count-based conditional: 0 or 1 instance of the resource
resource "aws_nat_gateway" "nat" {
  count         = var.create_nat_gateway ? 1 : 0
  subnet_id     = aws_subnet.public["public-1"].id
  allocation_id = aws_eip.nat[0].id
}

# for_each-based conditional: build a set that's either empty or populated
resource "aws_eip" "nat" {
  for_each = var.create_nat_gateway ? toset(["nat-eip"]) : toset([])
  domain   = "vpc"
}
```
Referencing a `count`-conditional resource elsewhere must account for the possibility that it doesn't exist: `aws_nat_gateway.nat[0].id` only works when `count = 1`; use `try(aws_nat_gateway.nat[0].id, null)` or a `one(aws_nat_gateway.nat[*].id)` splat pattern if the reference needs to gracefully handle the zero case.

> **Industry Best-Practice Notes**
> - Prefer the `for_each` + `toset([...])`/`{}` pattern over `count = condition ? 1 : 0` whenever the resource could plausibly become "more than one, conditionally" later — it future-proofs the code without a rewrite, and (per Domain 4b) avoids any index-based instability if the condition's inputs change.
> - Conditional resource creation is also exactly what module `variables.tf` "feature flag" inputs are for (e.g. `enable_nat_gateway = true/false` on a VPC module) — see Module-Focused Q5 below.

---

### 6. Use Data Sources to Reference AMIs
**Requirement:** Use `data "aws_ami"` to fetch the latest Amazon Linux 2 AMI.

```hcl
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
}
```

> **Industry Best-Practice Notes**
> - `most_recent = true` means your `plan` output can change **without you touching any `.tf` file** — a new AMI patch release upstream will show up as a diff on `aws_instance.web` the next time anyone runs `plan`. This is desired for security-patch currency, but it means AMI-sourced instances should sit behind an **Auto Scaling Group with a launch template** (so a "new AMI available" diff triggers a controlled instance *replacement* rotation) rather than a bare `aws_instance`, where an unexpected AMI change could force an unplanned in-place-incompatible replacement.
> - Always set `owners = ["amazon"]` (or your own trusted account ID) explicitly — never omit `owners`, since AMI *names* are not unique across the public AMI catalog and an unscoped filter can match an AMI published by an untrusted third party.

---

### 7. Pass Variables Using `terraform.tfvars`
**Requirement:** Organize and load variables from `.tfvars` files.

Already demonstrated throughout — `terraform.tfvars` (auto-loaded) plus named files like `dev.tfvars`/`prod.tfvars` (loaded explicitly via `-var-file=`) as shown in Intermediate Q4.

> **Industry Best-Practice Notes**
> - Recall the full **precedence order** (Domain 4a): CLI `-var` > `*.auto.tfvars` (auto-loaded, alphabetical) > `terraform.tfvars` (auto-loaded) > `TF_VAR_*` environment variables > `default` in the variable block. Mixing auto-loaded `.auto.tfvars` files with explicit `-var-file=` files for different purposes (e.g., `common.auto.tfvars` for shared defaults, `-var-file=prod.tfvars` for environment overrides) is a clean, common pattern — just document which files are auto-loaded so a teammate isn't confused about why a value changed with no visible flag.
> - Never commit a `.tfvars` file containing real secrets (API keys, DB passwords) to Git — add `*.tfvars` to `.gitignore` except for a checked-in `*.tfvars.example` template, and inject real secrets via `TF_VAR_*` env vars from a CI secrets store instead.

---

### 8. Define Multiple Security Groups Dynamically
**Requirement:** Use `for_each` with a map to create multiple security groups.

```hcl
variable "security_groups" {
  type = map(object({
    description = string
    ingress_ports = list(number)
  }))
  default = {
    web = { description = "Web tier SG", ingress_ports = [80, 443] }
    app = { description = "App tier SG", ingress_ports = [8080] }
  }
}

resource "aws_security_group" "tiered" {
  for_each    = var.security_groups
  name        = "${each.key}-sg"
  description = each.value.description
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "${each.key}-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "tiered_ingress" {
  for_each = {
    for pair in flatten([
      for sg_name, sg in var.security_groups : [
        for port in sg.ingress_ports : { key = "${sg_name}-${port}", sg_name = sg_name, port = port }
      ]
    ]) : pair.key => pair
  }

  security_group_id = aws_security_group.tiered[each.value.sg_name].id
  from_port          = each.value.port
  to_port             = each.value.port
  ip_protocol         = "tcp"
  cidr_ipv4           = "10.0.0.0/16"
}
```
The nested `flatten([for ... : [for ... : {...}]])` pattern is the standard way to turn a "map of lists" into a single flat map keyed uniquely per rule — necessary because `for_each` requires a flat map or set, not a nested structure.

> **Industry Best-Practice Notes**
> - This flatten-and-key pattern shows up constantly in real infrastructure code (any "one resource per combination of two dimensions" scenario) — it's worth memorizing the shape rather than re-deriving it each time.
> - Keep the security-group *definition* (what it's for) and its *rules* (what traffic it allows) in separate resources, as shown — this mirrors the AWS API itself (a security group and its rules are genuinely separate objects) and lets `for_each` add/remove individual rules without ever touching the group's identity/ID.

---

### 9. Import Existing Resources
**Requirement:** Use `terraform import` to bring an existing S3 bucket under Terraform management.

```hcl
# 1. Write the resource skeleton first
resource "aws_s3_bucket" "existing" {
  bucket = "my-existing-bucket-name"
}

# 2. Import (legacy CLI form)
# terraform import aws_s3_bucket.existing my-existing-bucket-name

# Modern equivalent (Terraform 1.5+): declarative import block, plannable
import {
  to = aws_s3_bucket.existing
  id = "my-existing-bucket-name"
}
```
```bash
terraform plan -generate-config-out=generated.tf
# Review generated.tf carefully, merge the useful parts into your real .tf files,
# then re-run plan to confirm zero diff before ever running apply.
```

> **Industry Best-Practice Notes**
> - **Never run `terraform apply` immediately after an import** without first running `terraform plan` and confirming it shows **no changes**. A diff at that point means your written configuration doesn't actually match the real resource, and applying would silently *modify* production infrastructure you only meant to start tracking.
> - Prefer the declarative `import` block over the legacy `terraform import` CLI command for anything beyond a one-off — it's reviewable in a pull request, works with `-generate-config-out` to draft the resource body for you, and can import many resources in a single `plan`/`apply` cycle instead of one CLI invocation per resource.
> - Import is common during a "brownfield adoption" — bringing infrastructure that was created by hand or by another tool under Terraform for the first time. Budget real time for this: large accounts often have resources with drifted or inconsistent tagging that surfaces only once you try to write matching config.

---

### 10. Provision Multiple EC2 Instances Using `for_each`
**Requirement:** Launch EC2 instances from a map of instance names and types.

```hcl
variable "instances" {
  type = map(object({
    ami_id        = string
    instance_type = string
  }))
  default = {
    "web-server"   = { ami_id = "ami-0e35ddab05955cf57", instance_type = "t3.micro" }
    "bastion-host" = { ami_id = "ami-0e35ddab05955cf57", instance_type = "t2.small" }
  }
}

resource "aws_instance" "fleet" {
  for_each      = var.instances
  ami           = each.value.ami_id
  instance_type = each.value.instance_type
  tags          = { Name = each.key }
}

output "instance_ids" {
  value = { for name, inst in aws_instance.fleet : name => inst.id }
}
```
Removing `"bastion-host"` from the map later destroys exactly that one instance — `"web-server"` is completely untouched, because each instance's Terraform address is keyed by its map key (`aws_instance.fleet["web-server"]`), not a positional index.

> **Industry Best-Practice Notes**
> - This is the direct, practical payoff of the count-vs-for_each material in Domain 4b: a map of named instances is the correct data shape whenever instances are conceptually *distinct things with identities* (a bastion host, a specific named server) rather than *interchangeable replicas* (an Auto Scaling Group's fleet, where `count`/ASG desired-capacity is actually appropriate).
> - For genuinely interchangeable, horizontally-scaled fleets (e.g., a stateless web tier), don't hand-roll `for_each`/`count` EC2 instances at all — use an **Auto Scaling Group** with a launch template, which handles replacement, health-check-based recycling, and scaling policy without you writing that logic in HCL (see Real-World Scenario 1).

---

## Advanced-Level Scenarios

### 1. Build a Multi-Tier Architecture Using Modules
**Requirement:** Separate modules for frontend, backend, and DB; set up networking between the tiers.

```hcl
module "network" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  subnets    = var.subnets
}

module "frontend" {
  source    = "./modules/ec2-asg"
  subnet_ids = module.network.public_subnet_ids
  sg_ids     = [module.security.frontend_sg_id]
}

module "backend" {
  source     = "./modules/ec2-asg"
  subnet_ids = module.network.private_subnet_ids
  sg_ids     = [module.security.backend_sg_id]
}

module "database" {
  source     = "./modules/rds"
  subnet_ids = module.network.database_subnet_ids
  sg_ids     = [module.security.database_sg_id]
}
```
The **security group chain** is the piece that actually enforces tier isolation: `frontend_sg` allows inbound 443 from the internet; `backend_sg` allows inbound only from `frontend_sg`'s ID (not a CIDR); `database_sg` allows inbound only from `backend_sg`'s ID. This means the DB tier is unreachable from anywhere except instances that are themselves members of the backend security group — a structural guarantee, not a convention.

> **Industry Best-Practice Notes**
> - Design the module boundary around **what changes together, and what different teams own** — not just "one module per AWS service." A network team often owns `modules/vpc`; an app team owns `modules/ec2-asg`; a DBA/platform team owns `modules/rds`. Module boundaries that mirror ownership boundaries make state/blast-radius isolation much more natural later.
> - Each tier module should have **its own state** where practical (separate root configs calling shared modules, wired together via `terraform_remote_state` or explicit variable-passing) rather than one giant root module for the whole architecture — this bounds the blast radius of a mistake to one tier instead of the entire stack (Domain 6/7 notes).

---

### 2. Use Dynamic Blocks for Security Group Rules
**Requirement:** Use `dynamic` blocks to define rules based on a variable list.

```hcl
variable "sg_rules" {
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}

resource "aws_security_group" "dynamic_sg" {
  name   = "dynamic-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
}
```
`dynamic "ingress"` iterates `var.sg_rules` and emits one inline `ingress { }` block per list item — this is the correct tool specifically for **nested, repeatable blocks inside a single resource** (the older, inline-`ingress{}`-block style of security group), as distinct from `for_each` on the whole `resource`, which creates multiple separate resource instances (Domain 4b notes cover this distinction in depth).

> **Industry Best-Practice Notes**
> - Where the modern per-rule resources (`aws_vpc_security_group_ingress_rule`) are available, prefer those with a resource-level `for_each` over `dynamic "ingress"` inside the older combined security-group resource — per-rule resources give you a `terraform state list` entry per rule, cleaner targeted changes, and no "one giant SG resource with an embedded list" diff noise when a single rule changes. Reach for `dynamic` blocks specifically when the nested-block target genuinely doesn't have a decomposed-resource equivalent (e.g., ALB listener rules, IAM policy statements).
> - Don't over-nest `dynamic` blocks (a `dynamic` inside a `dynamic`) purely to save lines — past one level, the code becomes materially harder to read than an equivalent `for_each` on a properly decomposed resource.

---

### 3. Split Configuration into Multiple Files and Environments
**Requirement:** Organize code into folders like `modules/`, `env/dev/`, `env/prod/`.

```
project/
├── modules/
│   └── vpc/, ec2/, rds/
└── envs/
    ├── dev/
    │   ├── main.tf         # calls modules/*, backend key = ".../dev/terraform.tfstate"
    │   └── dev.tfvars
    └── prod/
        ├── main.tf         # calls the SAME modules/*, backend key = ".../prod/terraform.tfstate"
        └── prod.tfvars
```
Each environment directory is its own root module with its own state, calling the same shared `modules/` — so a change to `modules/vpc/main.tf` doesn't automatically apply anywhere; each environment must independently run `terraform plan`/`apply` against the new module version, giving you a deliberate promotion gate between dev and prod.

> **Industry Best-Practice Notes**
> - This directory-per-environment layout is exactly the DRY problem Terragrunt exists to solve (files 13-15) — plain Terraform's answer is "duplicate the calling code, share the modules," which is fine for 2-3 environments but becomes a real maintenance burden at 10+ near-identical environments. Recognize when you've outgrown hand-rolled directories and it's time for a wrapper tool.
> - Within a single environment's directory, splitting into `network.tf`, `compute.tf`, `iam.tf`, `outputs.tf` (rather than one giant `main.tf`) is purely a human-readability convention — Terraform concatenates every `.tf` file in a directory into one configuration regardless of filename, so name files by *concern*, not by resource type count.

---

### 4. Terraform CI/CD Integration (GitHub Actions / GitLab CI)
**Requirement:** Create CI pipelines that run `terraform init`, `plan`, and `apply`; secure secrets and manage environments.

```yaml
# .github/workflows/terraform.yml
name: Terraform
on:
  pull_request:
  push:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    permissions:
      id-token: write   # required for OIDC — see note below
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3

      - name: Configure AWS credentials (OIDC, no static keys)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-terraform
          aws-region: ap-south-1

      - run: terraform fmt -check
      - run: terraform init
      - run: terraform validate
      - run: terraform plan -out=tfplan
      - if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve tfplan
```

> **Industry Best-Practice Notes**
> - **Use OIDC federation to assume an IAM role, never long-lived AWS access keys stored as CI secrets.** A leaked long-lived key is a standing risk until manually rotated; an OIDC-issued token is short-lived and scoped to that specific pipeline run. This is the single highest-impact security change most teams' Terraform CI setups are still missing.
> - **Never auto-apply on every push to `main` without a `plan` artifact review gate** for anything beyond a low-risk sandbox — the pattern above runs `plan` on every PR (visible to reviewers as a CI comment via a plan-posting action) and only `apply`s the *exact reviewed plan file* (`tfplan`) on merge, so what gets applied is provably what was reviewed, not a fresh plan computed at apply-time that could differ if state drifted between review and merge.
> - Separate pipelines (or at minimum, separate approval gates) per environment — a dev `apply` should never be one accidental branch-protection misconfiguration away from also running against prod.

---

### 5. Use `locals` and Complex Data Structures
**Requirement:** Simplify code using `locals` with nested maps/lists.

```hcl
locals {
  environments = {
    dev  = { instance_type = "t3.micro",  min_size = 1, max_size = 2 }
    prod = { instance_type = "m5.large",  min_size = 3, max_size = 10 }
  }

  common_tags = {
    ManagedBy = "Terraform"
    Repo      = "infra-aws"
  }

  # Merge a per-environment tag set into the common tags without repeating ManagedBy/Repo everywhere
  env_tags = {
    for env, cfg in local.environments :
    env => merge(local.common_tags, { Environment = env })
  }
}

resource "aws_launch_template" "app" {
  for_each      = local.environments
  instance_type = each.value.instance_type
  tags          = local.env_tags[each.key]
}
```

> **Industry Best-Practice Notes**
> - `locals` are the right tool for **computed, derived values** (a merged tag map, a naming convention string, a filtered list) — they are not a substitute for `variable`s, which is how a module or config actually accepts external input. A common beginner mistake is putting environment-specific values that *should* vary per caller into a `locals` block instead of a `variable`, which then requires editing the module's source code to reconfigure it for a new environment.
> - Keep nested `locals` structures to 2-3 levels deep at most — beyond that, a mistake in one nested `for` expression becomes very hard to trace in `terraform console` or plan output. If the structure is getting complex enough to need deep nesting, consider whether it should be a module input instead.

---

### 6. Create and Manage an EKS Cluster
**Requirement:** Provision an EKS cluster; deploy a sample Kubernetes app.

```hcl
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"
  cluster_name    = "demo-cluster"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 5
      desired_size   = 2
    }
  }
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ap-south-1"
}
```
```bash
aws eks update-kubeconfig --name demo-cluster --region ap-south-1
kubectl apply -f sample-app-deployment.yaml
```

> **Industry Best-Practice Notes**
> - Deploying Kubernetes *workloads* (Deployments, Services) via raw `kubectl apply` after a Terraform-provisioned cluster is a completely normal split of responsibility — Terraform provisions the cluster/infrastructure, a separate tool (Helm, Argo CD, plain `kubectl`/GitOps) manages what runs *inside* it. Resist the temptation to manage every Kubernetes manifest through the Terraform `kubernetes` provider for a fast-moving app layer; it couples your app deployment cadence to your infrastructure `apply` cadence, which is usually the wrong coupling.
> - Always use a well-maintained community module (like `terraform-aws-modules/eks/aws` above) rather than hand-rolling EKS's control plane + node group + IAM + security-group wiring from scratch — EKS has enough moving parts (OIDC provider for IRSA, node IAM roles, cluster security group rules) that reinventing it is a significant, easy-to-get-subtly-wrong effort with little benefit over the audited community module.

---

### 7. Use a Remote Module from GitHub
**Requirement:** Reference a public module and pass variables to it.

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# Direct GitHub source (not via the Registry) — pin to a tag or commit SHA
module "custom" {
  source = "git::https://github.com/myorg/tf-modules.git//vpc?ref=v1.2.0"
}
```

> **Industry Best-Practice Notes**
> - Registry modules (`source = "terraform-aws-modules/vpc/aws"`) get you semantic version constraints (`~> 5.0`) resolved automatically by `terraform init`; direct Git sources require you to pin an exact `?ref=` yourself — **always pin to a tag or commit SHA, never a branch name** (`?ref=main`), because a branch is a moving target and your "identical" `apply` next month could pull in unreviewed changes.
> - Before adopting any public module (Registry or GitHub), check: last-updated date, open issue count, and whether it's published by HashiCorp Verified/Partner tier or an individual — this is the Provider/Module trust-tier judgment from Domain 2, applied to modules instead of providers.

---

### 8. Terraform State Management: Move/Remove Resources
**Requirement:** Use `terraform state mv`, `rm`, and `taint`/`-replace` commands.

```bash
# Rename a resource in state to match a renamed .tf block (no destroy/recreate)
terraform state mv aws_instance.old_name aws_instance.new_name

# Move a resource into a module without destroying it
terraform state mv aws_instance.web module.web_tier.aws_instance.web

# Stop tracking a resource WITHOUT destroying the real infrastructure
terraform state rm aws_s3_bucket.legacy

# Force a resource to be destroyed and recreated on the next apply
# (modern replacement for the deprecated `terraform taint`)
terraform apply -replace="aws_instance.web"
```

> **Industry Best-Practice Notes**
> - Prefer a **`moved` block** (Domain 6 notes) over manual `terraform state mv` wherever the refactor is going into version control — a `moved` block is declarative, reviewable in a pull request, and runs automatically for every teammate's next `plan`, whereas a manual `state mv` command is a one-time, easy-to-forget, un-reviewable action that only fixes *your* local/remote state, not the next person's understanding of why the resource moved.
> - `terraform state rm` **does not delete the real AWS resource** — it only removes Terraform's tracking of it. This is the correct move when decommissioning Terraform management of a resource (e.g., handing it off to a different tool or team) but the wrong move if your actual goal is deleting the resource (use `terraform destroy -target=` or just remove it from config and `apply`).
> - `taint` is deprecated in modern Terraform in favor of `apply -replace=` — the newer form shows the replacement in the plan output for review before it happens, rather than silently marking a resource for forced replacement on the *next* apply with no visible diff explaining why.

---

### 9. Handle Resource Dependencies with `depends_on`
**Requirement:** Manage dependencies explicitly using `depends_on`.

```hcl
resource "aws_iam_role_policy_attachment" "app_policy" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app.arn
}

resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.app.name

  # The instance's IAM profile attribute doesn't textually reference the POLICY
  # ATTACHMENT, only the instance profile — but the app running on the instance
  # needs the policy to actually be attached before it boots and tries to call AWS
  # APIs. This ordering can't be inferred from attribute references, so it's forced
  # explicitly.
  depends_on = [aws_iam_role_policy_attachment.app_policy]
}
```

> **Industry Best-Practice Notes**
> - `depends_on` should be the **exception, not the default** — reach for it only after confirming an implicit dependency (a direct attribute reference, which Domain 4c covers as the preferred approach) genuinely can't express the ordering you need. Overusing `depends_on` "just to be safe" creates a dependency graph that's harder to reason about and can introduce needless serialization that slows down `apply` for resources that didn't actually need to wait.
> - `depends_on` accepts a list — document *why* each entry is there with a comment (as shown above), because six months later "why does this depend on that policy attachment" is not obvious from the code alone, and someone may be tempted to "clean it up" and reintroduce the race condition it was preventing.

---

### 10. Multiple AWS Profiles/Regions
**Requirement:** Use provider aliasing for deployments across accounts or regions.

```hcl
provider "aws" {
  alias  = "primary"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "dr"
  region = "us-east-1"
}

resource "aws_instance" "primary_app" {
  provider      = aws.primary
  ami           = var.ami_id_primary
  instance_type = var.instance_type
}

resource "aws_instance" "dr_app" {
  provider      = aws.dr
  ami           = var.ami_id_dr
  instance_type = var.instance_type
}

module "network_dr" {
  source = "./modules/vpc"
  providers = {
    aws = aws.dr
  }
  cidr_block = "10.1.0.0/16"
}
```

> **Industry Best-Practice Notes**
> - Notice `module "network_dr"` explicitly maps `providers = { aws = aws.dr }` — a module must **always** be told which aliased provider to use via its own `providers` block; it never implicitly inherits the *aliased* default the way a bare resource in the root module can. Forgetting this is one of the most common multi-region-module mistakes, and it fails loudly at `plan` time (Terraform requires an explicit provider mapping into child modules using non-default providers).
> - Cross-account deployments (as opposed to just cross-region) should combine provider aliasing with **`assume_role`** in each aliased provider block, pointing at a role in the target account, rather than juggling separate static credential sets per account — this is both more secure (short-lived assumed-role credentials) and centralizes trust in one set of long-lived credentials that has `sts:AssumeRole` permission into each target account.

---

## Module-Focused Practice

### 1. Module for EC2 with Custom Security Group
**Requirement:** Reusable EC2 module accepting AMI ID, instance type, and custom security group rules; outputs instance ID and public IP.

```hcl
# modules/ec2-with-sg/variables.tf
variable "ami_id"          { type = string }
variable "instance_type"   { type = string }
variable "vpc_id"          { type = string }
variable "ingress_rules" {
  type = list(object({ port = number, cidr = string, description = string }))
}

# main.tf
resource "aws_security_group" "this" {
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each          = { for r in var.ingress_rules : "${r.port}-${r.cidr}" => r }
  security_group_id = aws_security_group.this.id
  from_port         = each.value.port
  to_port           = each.value.port
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value.cidr
  description       = each.value.description
}

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.this.id]
}

# outputs.tf
output "instance_id" { value = aws_instance.this.id }
output "public_ip"   { value = aws_instance.this.public_ip }
```

> **Industry Best-Practice Notes**
> - Bundling the security group *inside* the EC2 module (rather than requiring the caller to build and pass one in) is a deliberate design choice with a tradeoff: it's more convenient for simple callers, but less flexible if two instances from this module need to *share* one security group. Decide this based on your actual reuse pattern — a lower-level "just the instance" module plus a separate "security group" module, composed by the caller, is more flexible; a bundled module is simpler for the common case.

### 2. Nested Module Usage
**Requirement:** A root module uses a `vpc` module and an `ec2` module internally, passing VPC outputs as EC2 inputs.

```hcl
module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
}

module "ec2" {
  source    = "./modules/ec2"
  subnet_id = module.vpc.public_subnet_ids[0]
  vpc_id    = module.vpc.vpc_id
}
```
> **Industry Best-Practice Notes**
> - This output → input chaining is the entire mechanism by which modules compose — there is no "magic" implicit wiring between modules; every cross-module value must be explicitly passed as shown. Terraform automatically sequences `module.vpc` before `module.ec2` because of this reference, exactly like implicit dependencies between plain resources (Domain 4c).
> - Avoid nesting modules more than 2-3 levels deep (a module that calls a module that calls a module) — beyond that, tracing "where did this value actually come from" during a `plan` review becomes genuinely difficult. Flatten by having the root module call several modules directly instead.

### 3. Parameterize Resource Count in a Module
**Requirement:** Support launching multiple EC2 instances via `count` or `for_each`, from a list/map of instances.

```hcl
variable "instances" {
  type = map(object({ instance_type = string }))
}

resource "aws_instance" "this" {
  for_each      = var.instances
  ami           = var.ami_id
  instance_type = each.value.instance_type
  tags          = { Name = each.key }
}

output "instance_ids" {
  value = { for k, v in aws_instance.this : k => v.id }
}
```
> **Industry Best-Practice Notes**
> - Expose this as a **map input**, not a plain `count` integer — a caller passing `instance_count = 3` gives you no way to give each instance a distinct, stable identity or configuration; a map keyed by logical name (as shown) does, and avoids the count index-shift problem entirely if the module is later asked to support heterogeneous instances (different types per name).

### 4. Write a Module for S3 Bucket Creation
**Requirement:** Accept parameters for versioning, lifecycle rules, and bucket policy; output bucket name and ARN.

```hcl
variable "bucket_name" {
  type = string
}
variable "enable_versioning" {
  type    = bool
  default = true
}
variable "lifecycle_days" {
  type    = number
  default = 90
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    id     = "expire-old-objects"
    status = "Enabled"
    expiration { days = var.lifecycle_days }
  }
}

output "bucket_name" { value = aws_s3_bucket.this.id }
output "bucket_arn"  { value = aws_s3_bucket.this.arn }
```
> **Industry Best-Practice Notes**
> - Always default `enable_versioning = true` and default to **blocking public access** (`aws_s3_bucket_public_access_block` with all four flags `true`) inside the module itself, rather than leaving it to every caller to remember — a module is the right place to bake in a secure-by-default posture, with an explicit opt-out variable for the rare legitimate public-bucket case, rather than an insecure default that every caller must remember to override.

### 5. Module with Conditional Logic
**Requirement:** A variable enables/disables creation of a resource (e.g., NAT Gateway) inside the module.

```hcl
variable "enable_nat_gateway" {
  type    = bool
  default = false
}

resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? toset(["nat"]) : toset([])
  domain   = "vpc"
}

resource "aws_nat_gateway" "this" {
  for_each      = var.enable_nat_gateway ? toset(["nat"]) : toset([])
  allocation_id = aws_eip.nat["nat"].id
  subnet_id     = var.public_subnet_id
}
```
> **Industry Best-Practice Notes**
> - Feature-flag variables like `enable_nat_gateway` are how production-grade modules (e.g. `terraform-aws-modules/vpc/aws`) let a dev environment skip an expensive resource (NAT Gateway billing) while prod enables it — always default expensive optional resources to `false` and require an explicit opt-in, so a first-time caller doesn't get billed for something they didn't realize was on by default.

### 6. Module for CloudWatch Alarms
**Requirement:** Create alarms for EC2 CPU utilization; accept threshold and alarm actions as variables.

```hcl
variable "instance_id" {
  type = string
}
variable "cpu_threshold" {
  type    = number
  default = 80
}
variable "alarm_actions" {
  type    = list(string)
  default = []
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "high-cpu-${var.instance_id}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods   = 3
  metric_name          = "CPUUtilization"
  namespace            = "AWS/EC2"
  period               = 300
  statistic            = "Average"
  threshold            = var.cpu_threshold
  dimensions           = { InstanceId = var.instance_id }
  alarm_actions        = var.alarm_actions
}
```
> **Industry Best-Practice Notes**
> - `evaluation_periods = 3` at a 300-second `period` means the alarm only fires after 15 minutes of sustained high CPU — deliberately avoiding a single momentary spike from paging someone at 3am. Tune `evaluation_periods`/`period` to match the actual noise tolerance of the workload, not just the default from a tutorial.
> - `alarm_actions` should point at an **SNS topic** wired to both a paging system (for prod) and/or an Auto Scaling policy (to actually respond by scaling out) — an alarm with no action is just a colored icon in a console nobody's watching.

### 7. DRY Modules for Multi-Tier Architecture
**Requirement:** A base network module used by frontend/backend/db modules; deploy all three tiers in separate subnets with isolated security groups.

Covered structurally in Advanced Q1 above — the `modules/vpc` "base network" module is called once by the root, and its subnet/security-group outputs feed into three separate tier modules (`frontend`, `backend`, `database`), each isolated by security-group chaining.

> **Industry Best-Practice Notes**
> - "DRY" here specifically means **the network module is defined once and referenced three times**, not that the three tier modules are identical to each other — resist the urge to force frontend/backend/db into one "generic tier module" just to reduce file count; they have genuinely different concerns (ASG vs. RDS) and forcing a shared abstraction across them usually produces a worse, harder-to-read result than three small, purpose-specific modules.

### 8. Use of `locals` in Modules
**Requirement:** Refactor a module to use `locals` for computed values like naming conventions or merged tags.

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags          = merge(local.common_tags, { Name = "${local.name_prefix}-app" })
}
```
> **Industry Best-Practice Notes**
> - Centralizing the naming convention and tag-merge logic in one `locals` block means a future change to the tagging standard (e.g., adding a mandatory `CostCenter` tag org-wide) is a one-line change in this module, applied consistently to every resource that references `local.common_tags` — versus hunting down and editing every individual `tags = {}` block by hand.

### 9. Output Propagation from Modules
**Requirement:** Capture module outputs in the root module and use them in another module (e.g., VPC's `subnet_id` used by an EC2 module).

Already demonstrated in Module-Focused Q2 and throughout Intermediate Q1-2 — `module.vpc.public_subnet_ids[0]` flowing into `module.ec2`'s `subnet_id` input is exactly this pattern.

> **Industry Best-Practice Notes**
> - When a value needs to flow through **two levels** (child module → root → a *different* child module, or root → module → grandchild module), it must be explicitly re-declared as both an `output` at the lower level and a `variable` passed at the higher level at every hop — Terraform has no mechanism for a value to "pass through" a level automatically. This is verbose by design: every module's inputs/outputs are a fully explicit, auditable contract.

### 10. Use Public Modules (Terraform Registry or GitHub)
**Requirement:** Integrate a public module (e.g., `terraform-aws-modules/vpc/aws`) and customize its behavior via variables.

Already demonstrated in full in Advanced Q7 above.

> **Industry Best-Practice Notes**
> - Read a public module's `variables.tf` (or its Registry-rendered "Inputs" table) before using it, rather than copy-pasting an example you found online — popular modules like `terraform-aws-modules/vpc/aws` have dozens of optional inputs, and the example you copy is rarely tuned for your actual requirements (e.g., it may enable a NAT Gateway per AZ, at a cost you didn't intend, or disable one you actually needed).

---

## Real-World Industry Scenarios

*These are larger, architecture-level scenarios — the goal is recognizing the right combination of services and Terraform features, not memorizing every line of HCL. Each includes the key Terraform mechanisms involved and the production considerations a real review would raise.*

### 1. Launch a Scalable Web Application
**Requirement:** VPC with public/private subnets; an Auto Scaling Group of EC2 instances behind an Application Load Balancer; security groups and target groups.

**Key pieces:** `aws_lb` (ALB, public subnets) → `aws_lb_target_group` → `aws_autoscaling_group` (private subnets, `aws_launch_template`) → security-group chain (ALB SG allows 443 from internet; ASG instance SG allows traffic only from the ALB SG).
```hcl
resource "aws_launch_template" "app" {
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.app.id]
}

resource "aws_autoscaling_group" "app" {
  desired_capacity    = 2
  min_size            = 2
  max_size            = 6
  vpc_zone_identifier = module.vpc.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.app.arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}
```
> **Best Practice:** Use `health_check_type = "ELB"` (not just `"EC2"`) on the ASG, so an instance failing the ALB's application-level health check is recycled even if the EC2 instance status itself looks healthy — this catches "instance is up but the app crashed" far faster than EC2-status-only checks.

### 2. Deploy a Multi-Tier Architecture
**Requirement:** Web (ALB + EC2), App (EC2), DB (RDS) tiers; private subnets for App/DB; routing, security groups, NAT Gateway.
This composes Real-World Q1 (web tier) with an App-tier ASG behind an *internal* ALB and an `aws_db_instance` in a dedicated database subnet group (`aws_db_subnet_group`), reachable only from the App tier's security group.
> **Best Practice:** Put the database in its **own dedicated subnet group** spanning at least two AZs (required for Multi-AZ RDS failover) — don't reuse the general "private subnet" used for app servers, so future NACL/routing changes for the app tier can't accidentally affect DB reachability.

### 3. Set Up Terraform CI/CD in GitHub Actions
**Requirement:** Pipeline running `fmt`, `validate`, `plan`, `apply`; environment secrets; separate staging/production workflows.
Covered in full in Advanced Q4 above (OIDC federation, plan-then-apply-the-artifact pattern, per-environment pipelines).

### 4. Terraform with Remote State in S3 and State Locking in DynamoDB
**Requirement:** Backend block with versioned, encrypted S3 bucket and DynamoDB locking.
Covered in full in Intermediate Q3 above (including the modern S3-native-locking alternative).

### 5. Manage IAM Roles and Policies
**Requirement:** IAM roles for EC2, Lambda, and ECS services; inline and managed policies; least-privilege access.
```hcl
resource "aws_iam_role" "ec2_role" {
  name = "ec2-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "ec2_inline" {
  name = "s3-read-only"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "${aws_s3_bucket.app_assets.arn}/*"
    }]
  })
}
```
> **Best Practice:** Prefer **customer-managed policies attached via `aws_iam_role_policy_attachment`** over inline policies (`aws_iam_role_policy`) for anything reused across multiple roles — inline policies exist only inside their one role and can't be independently versioned, reviewed, or reused. Reserve inline policies for genuinely role-specific, one-off permissions. Always scope `Resource` to the specific ARN (as shown) instead of `"*"` — least privilege is a specific, checkable property, not a vague goal.

### 6. Provision an EKS Cluster with Worker Nodes
**Requirement:** Use `terraform-aws-modules/eks/aws`; configure node groups with scaling; output kubeconfig.
Covered in full in Advanced Q6 above.

### 7. Deploy a Serverless Application Using Lambda and API Gateway
**Requirement:** Lambda functions with IAM roles; API Gateway integration; CloudWatch logging.
```hcl
resource "aws_lambda_function" "api" {
  function_name = "api-handler"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = data.archive_file.lambda_zip.output_path
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "app-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type    = "AWS_PROXY"
  integration_uri     = aws_lambda_function.api.invoke_arn
}
```
> **Best Practice:** Grant API Gateway explicit `aws_lambda_permission` to invoke the function (a separate resource from the IAM execution role) — this is a commonly missed step since API Gateway's ability to *invoke* Lambda is a resource-based Lambda permission, distinct from the Lambda function's own *execution* role that governs what the function itself can call.

### 8. Blue/Green Deployment Using Terraform Workspaces
**Requirement:** `dev`/`staging`/`prod` workspaces; deploy different versions of the same infrastructure; automate promotion.
Builds on Intermediate Q4. For true blue/green (not just environment separation), pair workspaces with a `variable "app_version"` and a weighted ALB target-group routing config, shifting traffic between a "blue" and "green" target group as the new version is validated.
> **Best Practice:** Recall the workspace isolation caveat from Domain 6 — workspaces isolate *state*, not accidental cross-environment `apply`s. For genuine blue/green production traffic-shifting, treat this as an application-deployment concern (best handled by CodeDeploy or a CD tool operating within infrastructure Terraform already stood up) rather than something Terraform's own `apply` cycle should drive directly.

### 9. Provision a Multi-Region Disaster Recovery Setup
**Requirement:** Two AWS regions via provider aliasing; sync state and DNS via Route 53 failover routing; `terraform_remote_state` for data sharing.
Covered in full in Advanced Q10 (provider aliasing) — add `aws_route53_health_check` + `aws_route53_record` with `failover_routing_policy` (PRIMARY/SECONDARY) pointing at each region's endpoint, and a `data "terraform_remote_state" "primary"` lookup so the DR region's config can reference primary-region outputs (e.g., a KMS key ARN it needs to replicate against).
> **Best Practice:** DR infrastructure that is never actually tested is not DR — schedule regular failover drills (automated or manual) that actually shift Route 53 traffic to the secondary region, not just a `terraform plan` that shows the DR resources "would" work.

### 10. Infrastructure Tagging Strategy
**Requirement:** Consistent tagging module; auto-apply `Owner`, `Environment`, `CostCenter`; enforce via pre-commit hooks or policy.
```hcl
# provider-level default tags — applied to every resource that supports tagging,
# without repeating the same tags block everywhere
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Repo      = "infra-aws"
    }
  }
}
```
> **Best Practice:** Use the provider's built-in `default_tags` block (shown above) for org-wide constants, and reserve resource-level `tags = {}` only for values that genuinely vary per resource (`Name`, `Owner`) — this guarantees the mandatory tags can never be forgotten on a new resource, since they're applied at the provider level rather than relying on every engineer remembering to copy a tags block. Enforce the mandatory-tag policy itself with **Sentinel** (HCP Terraform) or **OPA/Checkov** in CI (Real-World Scenario 14) so an untagged resource fails the pipeline rather than relying on code review alone.

### 11. Manage Secrets with AWS SSM or Secrets Manager
**Requirement:** Store DB credentials in SSM Parameter Store or Secrets Manager; reference via data sources; pass securely to EC2/Lambda.
```hcl
resource "aws_secretsmanager_secret" "db_password" {
  name = "prod/db/password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password   # supplied as an ephemeral/write-only value, never committed to .tfvars
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
}

resource "aws_db_instance" "app" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```
> **Best Practice:** This is the exact scenario `ephemeral` values and write-only arguments (Terraform 1.10+, Domain 4c) were built for — writing the *initial* secret value using an ephemeral input means it never lands in the state file at all, closing the plaintext-in-state gap that `sensitive = true` alone does not close. Reading it back for use *within the same apply* (as the `data` source does above) still persists the read value into state under older patterns — check the current write-only argument support for the specific resource before assuming the read path is also state-safe.

### 12. Scheduled Auto Start/Stop of EC2 Instances
**Requirement:** Use `aws_instance` with Lambda and CloudWatch rules; schedule expressions to cut costs outside business hours.
```hcl
resource "aws_cloudwatch_event_rule" "stop_nightly" {
  name                = "stop-dev-instances-nightly"
  schedule_expression = "cron(0 20 * * ? *)"   # 8pm daily
}

resource "aws_cloudwatch_event_target" "stop_lambda" {
  rule      = aws_cloudwatch_event_rule.stop_nightly.name
  arn       = aws_lambda_function.stop_instances.arn
}
```
> **Best Practice:** Scope the automation Lambda's IAM permissions and its instance-selection logic to a **tag filter** (e.g., `Schedule = "office-hours"`) rather than a hardcoded instance ID list — this is a direct real-world payoff of the tagging strategy from Scenario 10, and means new instances opt into the schedule automatically just by being tagged correctly, with zero Terraform changes required.

### 13. Monitor Infrastructure with CloudWatch Dashboards
**Requirement:** Custom metrics and dashboards via Terraform; monitor EC2/RDS/EKS metrics; alarm thresholds.
```hcl
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "app-overview"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [["AWS/EC2", "CPUUtilization", "InstanceId", var.instance_id]]
          period  = 300
          stat    = "Average"
        }
      }
    ]
  })
}
```
> **Best Practice:** Author the dashboard body via `jsonencode()` over a nested HCL object (as shown) rather than a raw JSON string literal — it gets HCL's own syntax validation and lets you interpolate variables directly into the structure, instead of manually string-concatenating JSON (which is fragile and a common source of dashboard-apply failures).

### 14. Use Sentinel or OPA for Policy-as-Code
**Requirement:** Guardrails like "no public S3 buckets" or "tag enforcement"; run policies during CI/CD or `apply`.
```
# Sentinel (HCP Terraform) — enforced organization-wide, before any apply, regardless of who runs it
import "tfplan/v2" as tfplan

s3_buckets = filter tfplan.resource_changes as _, rc {
  rc.type is "aws_s3_bucket_public_access_block" and rc.mode is "managed"
}

main = rule {
  all s3_buckets as _, bucket {
    bucket.change.after.block_public_acls is true
  }
}
```
> **Best Practice:** Sentinel policies attached to an HCP Terraform workspace are enforced **regardless of who or what triggers the run** through that workspace, which is the key advantage over CI-pipeline-only checks (like Checkov/OPA in GitHub Actions) — a CI-only check can be bypassed by anyone who can `apply` outside that specific pipeline (e.g., from a laptop with local credentials), whereas Sentinel is enforced by the run pipeline itself. Use CI-stage tools like Checkov/tfsec for fast, pre-plan feedback in a PR, and Sentinel/OPA-in-HCP as the actual enforcement backstop.

### 15. Automate SSL Certificate Management
**Requirement:** Provision ACM certificates; DNS validation via Route 53; attach to ALB/CloudFront.
```hcl
resource "aws_acm_certificate" "app" {
  domain_name       = "app.example.com"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  for_each = { for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => dvo }
  zone_id  = var.zone_id
  name     = each.value.resource_record_name
  type     = each.value.resource_record_type
  records  = [each.value.resource_record_value]
  ttl      = 60
}

resource "aws_acm_certificate_validation" "app" {
  certificate_arn         = aws_acm_certificate.app.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}
```
> **Best Practice:** `aws_acm_certificate_validation` is a **wait resource** — it has no real AWS counterpart, it exists purely to block Terraform's dependency graph until ACM reports the certificate as validated, before anything referencing the certificate (an ALB listener, a CloudFront distribution) tries to attach it. Always insert it between certificate creation and certificate use, or the ALB/CloudFront `apply` can race ahead and fail against a not-yet-validated certificate.

### 16. Use Terraform to Provision Azure/AWS Hybrid Infrastructure
**Requirement:** Configure providers for both AWS and Azure; VPC in AWS, VNet in Azure; shared secrets/monitoring across clouds.
```hcl
provider "aws" {
  region = "ap-south-1"
}

provider "azurerm" {
  features {}
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "azurerm_virtual_network" "main" {
  name                = "main-vnet"
  address_space       = ["10.1.0.0/16"]
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}
```
> **Best Practice:** Terraform's multi-provider support (any provider, in any combination, in one configuration) is precisely what makes this possible — but a true hybrid network still needs an actual network path between the clouds (a Site-to-Site VPN or a dedicated interconnect like AWS Direct Connect + Azure ExpressRoute) that Terraform can provision the *endpoints* of but cannot make cross-cloud traffic route through by itself. Note also: your course material is AWS-focused and the certification exam itself is AWS/GCP/Azure-agnostic at the concept level but doesn't test Azure resource specifics — treat this scenario as "know that multi-provider configs are possible and how aliasing/provider blocks work," not as a reason to learn the AzureRM provider deeply for this exam.

### 17. Import Legacy Resources to Terraform
**Requirement:** Use `terraform import` to bring existing infrastructure under code; clean up and map state to configuration; validate with `plan`.
Covered in full in Intermediate Q9 above (including the modern `import` block and `-generate-config-out` workflow).
> **Best Practice:** Budget significantly more time for a legacy-import project than the line-count of the resulting `.tf` files suggests — the actual work is reverse-engineering *why* the existing resource is configured the way it is (a security group rule with no obvious purpose, a hardcoded value that turns out to be load-bearing) before you can confidently write matching configuration, not the mechanical import step itself.

### 18. Create an Audit-Ready Logging and Monitoring Setup
**Requirement:** Enable AWS Config and CloudTrail via Terraform; stream logs to a central S3 bucket; apply retention/lifecycle policies.
```hcl
resource "aws_cloudtrail" "org_trail" {
  name                          = "org-audit-trail"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}

resource "aws_config_configuration_recorder" "main" {
  name     = "main-recorder"
  role_arn = aws_iam_role.config_role.arn
}
```
> **Best Practice:** `is_multi_region_trail = true` and `enable_log_file_validation = true` are both easy to forget defaults-off settings that materially matter for a real audit trail — a single-region trail misses activity in every other region, and without log file validation there's no cryptographic guarantee the stored logs weren't tampered with after the fact. Apply an S3 Object Lock / write-once retention policy on the audit-log bucket so even an account with delete permissions can't remove evidence within the retention window.

### 19. Onboard New Environments with a Single Command
**Requirement:** Parameterize environment creation (dev/qa/uat/prod); modules deploy identical infrastructure per environment; separate state/secrets per environment.
This is the direct capstone of Advanced Q3 (directory-per-environment) combined with Terragrunt's DRY environment pattern (files 13-15) — a new environment becomes: one new `envs/<name>/` directory (or, in Terragrunt, one new `env.hcl` plus a copy of the standard `terragrunt.hcl` include pattern) with its own `.tfvars`/`inputs`, calling the exact same shared modules everyone else uses.
> **Best Practice:** "Single command" onboarding is a strong signal you've outgrown copy-pasted root-module directories and should adopt Terragrunt (or an internal equivalent) — the whole point of files 13-15's DRY patterns is collapsing "create a new environment" from "copy an entire directory tree and edit six files" down to "add one small config file that inherits everything else."

### 20. Implement Cost Optimization with Auto Scaling and Spot Instances
**Requirement:** Mixed instance policies in an Auto Scaling Group; balance On-Demand and Spot with fallback strategies; predictive scaling or schedules.
```hcl
resource "aws_autoscaling_group" "app" {
  desired_capacity = 4
  min_size         = 2
  max_size         = 10

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 2   # guarantee a stable floor of On-Demand
      on_demand_percentage_above_base_capacity = 25  # of anything above the floor, 25% On-Demand
      spot_allocation_strategy                 = "capacity-optimized"
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.app.id
      }
      override {
        instance_type = "t3.medium"
      }
      override {
        instance_type = "t3a.medium"
      }
    }
  }
}
```
> **Best Practice:** `on_demand_base_capacity` is the mechanism that prevents a Spot-interruption storm from ever taking a workload to zero capacity — it guarantees a minimum floor of stable On-Demand instances regardless of Spot availability, with only the *elastic* portion above that floor exposed to Spot pricing/interruption risk. Always list **multiple instance-type overrides** (as shown with `t3.medium`/`t3a.medium`) — `spot_allocation_strategy = "capacity-optimized"` can only diversify across a Spot interruption event if there's more than one instance type/pool for it to spread across.

---

**This is the final file in the notes set.** Return to [00-INDEX.md](00-INDEX.md) for the full course map, or [12-bonus-challenges-exam-prep.md](12-bonus-challenges-exam-prep.md) for exam-day logistics and the final cross-domain capstone questions.
