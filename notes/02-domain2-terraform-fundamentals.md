# Domain 2 — Terraform Fundamentals

*Official exam objectives covered: 2a (Install and version providers), 2b (How Terraform uses providers), 2c (Multi-provider configuration), 2d (How Terraform uses and manages state)*
*Course lectures folded in: Resource and Providers, Provider Tiers, Create GitHub Repository through Terraform, AWS Provider Authentication Configuration, Terraform Provider Versioning, Dependency Lock File, Multiple Provider Configuration, Overview of Terraform State File, Desired State vs Current State, Terraform Refresh*

---

## 1. What a Provider Actually Is

### Definition
A provider is a **plugin** — a separate executable, downloaded independently of Terraform Core — that translates HCL resource blocks into real API calls for one specific platform. `hashicorp/aws` knows how to call EC2's `RunInstances`, S3's `CreateBucket`, etc. Terraform Core itself contains **zero** platform-specific logic; it only knows how to parse HCL, build a dependency graph, and hand off work to whichever provider owns a given resource type.

```mermaid
sequenceDiagram
    participant You
    participant Core as Terraform Core
    participant Plugin as AWS Provider Plugin
    participant API as AWS API

    You->>Core: terraform apply
    Core->>Core: Parse .tf files, build dependency graph
    Core->>Plugin: "create this aws_instance" (via plugin RPC protocol)
    Plugin->>API: RunInstances (real HTTPS call, signed with SigV4)
    API-->>Plugin: instance ID, ARN, attributes
    Plugin-->>Core: resource attributes
    Core->>Core: Write result into terraform.tfstate
```

### What if Terraform Core *did* have AWS knowledge baked in?
This is worth imagining to understand why the plugin architecture matters: every new AWS service (there are hundreds) would require a new Terraform Core release. Every provider bug would block on the Terraform Core release cycle. Instead, `hashicorp/aws` ships its own releases, on its own schedule, and Azure/GCP/Kubernetes/GitHub/Vault providers all evolve completely independently — this is *why* Terraform can support 4,000+ providers on the Registry without Core becoming an unmaintainable monolith.

---

## 2. Provider Tiers (know this for the exam)

| Tier | Maintainer | Trust level | Example |
|---|---|---|---|
| **Official** | HashiCorp itself | Highest | `hashicorp/aws`, `hashicorp/vault` |
| **Partner** | Verified third-party company | Vendor-maintained, HashiCorp-verified | `datadog/datadog`, `mongodb/mongodbatlas` |
| **Community** | Individual/community contributor | No HashiCorp guarantee | Hundreds of smaller, narrow-purpose providers |
| *Archived* | Formerly active, no longer maintained | Avoid for new work | — |

**Exam trap:** "Official" does not mean "bundled into Terraform." Even `hashicorp/aws` is downloaded separately on `terraform init`.

**What if you use an unmaintained Community-tier provider in production?** If it breaks against a new API version, or has a security bug, there's no vendor SLA and possibly no active maintainer to fix it — you either fork and patch it yourself, or you're stuck. Audit the provider's GitHub activity (last commit date, open issue count, whether maintainers respond) before depending on a Community-tier provider for anything business-critical.

---

## 3. Installing and Versioning Providers (Objective 2a)

### The `required_providers` block
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"   # registry namespace/name
      version = "~> 5.0"          # version constraint
    }
  }
}
```
`terraform init` reads this, downloads the matching plugin binary into `.terraform/providers/`, and records the *exact* resolved version in `.terraform.lock.hcl`.

### Version constraint syntax — every variant, with consequences
| Constraint | Meaning | Real consequence |
|---|---|---|
| `= 5.31.0` | Exactly this version | Safest for reproducibility; you must manually bump it for any update, including security patches |
| `>= 5.0` | This version or newer | **Dangerous** — a future `terraform init` on a new machine could silently pull a breaking major version |
| `~> 5.0` | Any `5.x`, never `6.0` | The standard recommendation — allows minor/patch updates, blocks breaking major changes |
| `~> 5.31` | Only `5.31.x` | Tighter — even minor updates within `5.x` are blocked, only patches allowed |
| *(no constraint)* | Latest available at `init` time | **Avoid** — different teammates/CI runs on different days get different versions |

**Example — the failure this actually causes:**
```hcl
# BAD: no version constraint
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
```
A teammate runs `terraform init` for the first time six months after the project started. The AWS provider has since released v6.0.0 with breaking changes (renamed arguments, removed resources). Their `terraform plan` fails with unfamiliar errors — not because their code is wrong, but because they silently got a different provider version than everyone else who set up the project earlier.

```hcl
# GOOD
terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}
```
Now `init` is guaranteed to stay within the `5.x` line — and the `.terraform.lock.hcl` file (committed to Git) pins the *exact* patch version + cryptographic hash, so literally every machine gets byte-identical provider binaries.

### Real-World Scenario 1 — The Silent Breaking Upgrade
A platform team's CI pipeline runs `terraform init` fresh on every build (no cached `.terraform` directory). One Tuesday, a provider's new major version ships with a renamed required argument. Every build starts failing simultaneously across every branch, with no code change having been made — the on-call engineer spends an hour confused before realizing the provider version itself moved. A `~>` constraint plus a committed lock file would have prevented this outright; the fix afterward is exactly that.

### Real-World Scenario 2 — Reproducing a Bug from Three Months Ago
An incident review needs to reproduce the exact infrastructure state from a deployment three months ago, including the exact provider behavior at that time (a provider bug was later patched, and the team needs to confirm it caused the incident). Because `.terraform.lock.hcl` was committed at every commit, `git checkout` to that commit plus `terraform init` reproduces the *exact* provider version from that day — without the lock file, this would be forensically impossible.

### The Dependency Lock File (`.terraform.lock.hcl`) in Detail
The version constraint in `required_providers` (`~> 5.0`) describes a *range*; it deliberately does not pin one exact version, so different runs could in principle resolve to different patch releases. The lock file is what removes that ambiguity — it's the actual pinning mechanism, generated automatically by `terraform init` the first time it resolves providers, and updated only when you explicitly ask it to.

**What it actually contains:**
```hcl
# .terraform.lock.hcl (excerpt — auto-generated, do not hand-edit)
provider "registry.terraform.io/hashicorp/aws" {
  version     = "5.62.0"
  constraints = "~> 5.0"
  hashes = [
    "h1:9J1n5z2j8...",   # cryptographic hash of the plugin binary
    "zh:1a2b3c4d...",    # additional per-platform hashes
  ]
}
```
The `hashes` list is what makes this a *security* mechanism, not just a version pin: every future `terraform init` re-downloads the provider and verifies its hash matches what's recorded here. If a provider's binary were ever tampered with (a compromised mirror, a supply-chain attack on the Registry), `init` would fail loudly with a checksum mismatch instead of silently installing a modified plugin.

**Multi-platform teams — a real gotcha:** by default, `init` only records hashes for the platform it ran on. A team where some engineers develop on macOS (arm64) and CI runs on Linux (amd64) can hit `Error: the current package for registry.terraform.io/hashicorp/aws ... doesn't match any of the checksums in the lock file` — not because anything is actually wrong, but because only one platform's hash was ever recorded. Fix it by generating hashes for every platform the team/CI actually uses:
```bash
terraform providers lock \
  -platform=windows_amd64 \
  -platform=darwin_amd64 \
  -platform=darwin_arm64 \
  -platform=linux_amd64
```

**What if you don't commit `.terraform.lock.hcl` to Git** (e.g., it's in `.gitignore` alongside `.terraform/`)? You lose the entire guarantee above — every fresh clone/CI run re-resolves versions independently within the `~>` range, so two engineers (or two CI runs a week apart, if a new patch version ships in between) can silently end up on different provider patch versions. Unlike `.terraform/` (a large, disposable local cache — correctly gitignored), `.terraform.lock.hcl` is small, human-readable, and meant to be committed and code-reviewed like any other dependency-pinning file (comparable to `package-lock.json` or `Gemfile.lock`).

### Real-World Scenario 3 — The Mixed-OS Checksum Failure
A team's engineers are split between Windows and macOS laptops; their CI runs on Linux containers. The lock file was first generated by a Windows engineer's `terraform init` and committed as-is. Every CI build immediately fails with a checksum-mismatch error — not a real security problem, just an incomplete lock file that never recorded Linux-platform hashes. Running `terraform providers lock -platform=linux_amd64` (in addition to the existing Windows platform) once, and recommitting the updated lock file, permanently fixes CI without anyone needing to touch application code.

---

## 4. How Terraform Uses Providers (Objective 2b)

### The `provider` block — configuring an instance of a plugin
```hcl
provider "aws" {
  region = "ap-south-1"
}
```
This doesn't just "select AWS" — it configures a specific, named **instance** of the AWS provider plugin (region, credentials, endpoints). You can configure **multiple instances of the same provider** using `alias` — this is the mechanism behind multi-region and multi-account Terraform, previewed in Domain 1 and covered fully in Domain 6.

### AWS Provider Authentication — every method, ranked by real-world use
```mermaid
flowchart TD
    A["Static keys hardcoded\nin provider block"] -->|"NEVER"| Z["Leak risk if committed"]
    B["Environment variables\nAWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY"] -->|"CI/CD"| Y["Injected as pipeline secrets"]
    C["Shared credentials file\n~/.aws/credentials + profile"] -->|"Local dev"| X["Per-developer, never committed"]
    D["IAM role on compute\n(EC2 instance profile / CodeBuild / ECS task role)"] -->|"Best"| W["No credentials exist to leak at all"]
```

**Example 1 — local development (named profile):**
```hcl
provider "aws" {
  region  = "ap-south-1"
  profile = "terraform-dev"   # reads the [terraform-dev] section of ~/.aws/credentials
}
```

**Example 2 — CI/CD (environment variables, provider block stays bare):**
```hcl
provider "aws" {
  region = "ap-south-1"
  # no credentials arguments at all
}
```
```bash
export AWS_ACCESS_KEY_ID=$CI_SECRET_KEY_ID
export AWS_SECRET_ACCESS_KEY=$CI_SECRET_ACCESS_KEY
terraform apply -auto-approve
```

**Example 3 — Terraform running *on* AWS itself (instance profile, zero credentials anywhere):**
```hcl
provider "aws" {
  region = "ap-south-1"
  # nothing here - the EC2 instance/CodeBuild project running this
  # has an IAM role attached, and the AWS SDK inside the provider
  # automatically discovers and uses those temporary credentials
}
```

**What if you hardcode static keys instead (the "never" branch above)?**
```hcl
provider "aws" {
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}
```
Beyond the leak risk (Domain 1's scenario), static keys also **don't rotate automatically** — if your security policy requires credential rotation every 90 days, hardcoded keys mean manually finding and updating every config that has them. Instance-profile-based auth (Example 3) rotates automatically, transparently, with zero code changes.

### Writing configuration with multiple *different* providers (Objective 2c)
A second, purely-AWS variety of the multi-provider idea introduced in Domain 1 — combining the official `aws` provider with the `hashicorp/random` provider, a common real pattern for generating unique, collision-free resource names:
```hcl
terraform {
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "logs" {
  bucket = "my-app-logs-${random_id.suffix.hex}"   # globally-unique bucket name, guaranteed
}
```
**Why this matters:** S3 bucket names must be globally unique across *all* AWS accounts worldwide. Hardcoding `"my-app-logs"` will collide with someone else's bucket sooner or later. `random_id` solves this without a human ever having to invent a unique suffix by hand.

### A Non-AWS Provider, Worked in Full: the GitHub Provider
A genuinely useful, real-world non-AWS example — using Terraform to manage a GitHub repository and its branch protection, alongside the AWS infrastructure that repository's CI deploys to. This is a good teaching example specifically because it proves the provider-plugin architecture isn't a marketing claim: the exact same `apply`, dependency graph, and state file that manage EC2 instances also manage GitHub resources, with no special-casing.

```hcl
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  token = var.github_token   # a GitHub Personal Access Token — never hardcode this
  owner = "my-org"
}

resource "github_repository" "app_repo" {
  name        = "my-app"
  description = "Application source, deployed via the CI pipeline below"
  visibility  = "private"
  auto_init   = true
}

resource "github_branch_protection" "main" {
  repository_id  = github_repository.app_repo.node_id
  pattern        = "main"
  required_status_checks {
    strict   = true
    contexts = ["ci/terraform-plan"]
  }
  required_pull_request_reviews {
    required_approving_review_count = 1
  }
}
```
```hcl
# variables.tf
variable "github_token" {
  type        = string
  sensitive   = true
  description = "GitHub PAT with repo + admin:repo_hook scopes"
}
```
```bash
# supplied via environment variable, never committed to .tfvars
export TF_VAR_github_token="ghp_xxx..."
terraform apply
```

**Reading the resources:** `github_repository` is the repository itself (name, visibility, default branch behavior); `github_branch_protection` is a *separate* resource that locks down the `main` branch — requiring a passing CI check and at least one PR approval before a merge is allowed. Notice `repository_id = github_repository.app_repo.node_id` — an implicit dependency (Domain 4c) exactly like `subnet_id = aws_subnet.main.id` would be for AWS resources; Terraform's dependency-graph mechanism doesn't care that this is GitHub instead of AWS.

**What if you manage the repository by hand instead (click "New Repository" in the GitHub UI)?** Branch protection rules, webhook configuration, and team access all become manually-configured, undocumented settings — exactly the same "configuration drift with no audit trail" problem Domain 1 describes for infrastructure, just applied to source control administration instead of servers.

### Provider Aliasing — Multiple Configured Instances of the *Same* Provider (Objective 2c)
Distinct from "two different providers" above: aliasing lets you configure the **same** provider more than once, each instance pointed at a different region, account, or credential set — the actual mechanism behind every "multi-region" or "multi-account" Terraform setup.

```hcl
provider "aws" {
  region = "ap-south-1"   # the DEFAULT, un-aliased instance
}

provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

resource "aws_instance" "primary" {
  # no `provider =` argument -> uses the default (un-aliased) provider block above
  ami           = data.aws_ami.primary_region.id
  instance_type = "t3.micro"
}

resource "aws_instance" "dr_standby" {
  provider      = aws.us_east   # explicitly targets the aliased instance
  ami           = data.aws_ami.dr_region.id
  instance_type = "t3.micro"
}
```
**The rule to internalize:** any resource that omits `provider = ` always uses the default, un-aliased provider block for that provider type. You only ever need `provider = aws.<alias>` on the specific resources that must use a *non-default* configured instance. Forgetting this argument on a resource that was meant to be aliased is a common, silent mistake — the resource simply gets created in the wrong region/account instead of failing loudly, because the default provider block is still perfectly valid, just not the one you intended.

**What if you don't use aliasing, and instead duplicate the entire configuration per region/account** (a full separate directory, copy-pasted, one per region)? You now have two (or more) codebases to keep in sync by hand — a bug fix or a new required tag has to be manually applied to every copy, and they inevitably drift apart over time. Aliasing keeps one codebase, with the region/account distinction expressed as data (which provider instance a resource targets), not as a fork of the code itself.

### Real-World Scenario 3 — Multi-Region Disaster Recovery via Aliasing
An e-commerce company runs its primary infrastructure in `ap-south-1` and maintains a warm standby in `us-east-1` for disaster recovery. Using two aliased `aws` provider blocks in one configuration, the same module (VPC, ASG, RDS read replica) is called twice — once against the default provider, once with `providers = { aws = aws.us_east }` — from one codebase. When the primary region has an outage, promoting the standby is a variable change and an `apply`, not a scramble to hand-build a second region's infrastructure from memory.

### Real-World Scenario 4 — Forgetting the `provider =` Argument
An engineer adds a new S3 bucket resource to a config that has both a default (`ap-south-1`) and an aliased (`eu-central-1`, for EU-only regulated data) AWS provider. They intend the new bucket to hold EU customer data, but forget to add `provider = aws.eu_central`. `terraform apply` succeeds without any error — the bucket is simply created in `ap-south-1`, the default region, silently violating the company's data-residency requirement. This is discovered weeks later during a compliance audit, not by Terraform, because omitting `provider =` is valid, ordinary syntax, not a mistake Terraform can detect on your behalf.

---

## 5. How Terraform Uses and Manages State (Objective 2d)

### What the state file is, precisely
`terraform.tfstate` is a JSON file that is Terraform's **only** record of what it has created and how each block in your `.tf` files maps to a real-world resource ID.

```mermaid
flowchart LR
    A["main.tf: resource aws_instance.web"] -.->|"tracked via"| B["terraform.tfstate:\naws_instance.web -> i-0abc123,\nall its attributes"]
    B -.->|"maps to"| C["Real EC2 instance in AWS"]
```

**What's actually stored:** every attribute of every resource, including ones you never explicitly set (auto-generated ARNs, default values assigned by AWS) — and critically, **all of it in plaintext**, regardless of whether a corresponding output is marked `sensitive` (full detail + the modern fix, ephemeral values, is in Domain 4c).

### What if there were no state file?
Terraform would have to either (a) query every possible AWS resource on every `plan` to guess what it might have created before (impossibly slow and ambiguous), or (b) have no way at all to know `aws_instance.web` in your code *is* `i-0abc123` in AWS — every `apply` would just create a new instance. State is not an implementation detail you can ignore; it's the mechanism that makes "declarative, idempotent" possible at all.

### Desired State vs. Current State — the exact comparison `plan` performs
| | Desired State | Current State |
|---|---|---|
| Lives in | Your `.tf` files | The real infrastructure |
| Recorded as | — | Cached in `terraform.tfstate`, refreshed by default on every `plan`/`apply` |

`terraform plan` is really a **three-way comparison**: your `.tf` config (desired) vs. the last-recorded state vs. the real infrastructure right now (fetched via a refresh). This is why manual console changes get *flagged*, not silently accepted:

**Worked example:**
1. Config says: `instance_type = "t3.small"` (desired)
2. State last recorded: `t3.micro` (from the last apply)
3. Someone changed it in the AWS Console to `t3.medium` (drift — real world diverged from state)

Run `terraform plan`:
- Terraform refreshes → discovers AWS actually has `t3.medium`
- Compares real `t3.medium` against desired `t3.small`
- **Proposes:** change `t3.medium` → `t3.small`

**Terraform never treats a manual console change as the new desired state.** Your `.tf` files are always the source of truth; drift is something `plan` surfaces and offers to correct, not something it silently adopts.

### `terraform refresh`
```bash
terraform refresh
```
Updates the state file to match real infrastructure, **without** changing any actual resource and without a full plan/apply cycle. Since Terraform 0.15.4+, `plan`/`apply` already refresh automatically by default (`-refresh=false` skips it) — but understand the standalone command conceptually; it's still exam-tested.

**What if you never refresh (or always pass `-refresh=false`)?** Terraform's plan will be computed against a *stale* recollection of reality. If someone changed something in the console last week and you've been running `-refresh=false` ever since, your `plan` output could be actively wrong — proposing "no changes" when the real infrastructure has actually drifted, or vice versa.

### Real-World Scenario 1 — Debugging "Terraform says no changes, but production is broken"
A team disables refresh in CI (`-refresh=false`) to speed up pipeline runs. A junior engineer manually edits a security group rule in the console during an incident, forgetting to update the Terraform code. For weeks, `terraform plan` reports "no changes needed" — because it's comparing against stale state, not reality. The drift is only discovered when a completely unrelated `apply` (which *does* refresh) suddenly proposes reverting the manual fix, confusing everyone about why "nothing changed" suddenly wants to change something.

### Real-World Scenario 2 — Multi-Person Team Discovers a Duplicate Resource
Two engineers, unaware of each other, each write `.tf` code to create "the" application security group, in two different Terraform root modules that don't share state. Both `apply` successfully — because Terraform state is scoped per root module/workspace, not global to the AWS account, nothing warns them. AWS now has two functionally-identical security groups, and neither engineer's Terraform config knows the other exists. This is why Domain 6/7 (remote state, state inspection, `terraform_remote_state`) matter — state must be a **shared**, discoverable source of truth across a team, not implicitly siloed per laptop.

---

## 6. Practice Questions

### Easy
1. Where does Terraform Core get its AWS-specific knowledge from?
2. What's the difference in trust level between an "Official" and a "Community" tier provider?
3. Which file records the exact resolved provider version (with hashes) after `terraform init`?

### Medium
4. Write a `required_providers` block allowing any `hashicorp/aws` version from `4.50.0` up to (but not including) `5.0.0`.
5. Explain why an S3 bucket name generated with `random_id` avoids a class of errors that a hardcoded bucket name would eventually hit.
6. A team disables refresh in CI for speed. Describe a concrete scenario where this causes `terraform plan` to report incorrect information.

### Hard
7. Compare the security posture of three AWS authentication methods (hardcoded static keys, environment variables in CI, and an EC2 instance profile) in terms of what happens if the CI server or EC2 instance is compromised.
8. Two engineers unknowingly create duplicate security groups because their Terraform projects don't share state. Propose two different fixes — one process-based, one architectural — that would have caught this before both `apply`s succeeded.

---
**Next:** [03-domain3-core-workflow.md](03-domain3-core-workflow.md)
