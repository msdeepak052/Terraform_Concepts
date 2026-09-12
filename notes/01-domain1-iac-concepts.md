# Domain 1 — Infrastructure as Code (IaC) Concepts

## 1. What is Infrastructure as Code?

### Core idea

* **IaC = managing infrastructure using code instead of manually creating it.**
* Infrastructure can include:

  * EC2
  * VPC
  * Subnets
  * Load Balancers
  * S3
  * Databases
  * DNS
* Terraform uses **declarative configuration**.

### Imperative vs Declarative

* **Imperative → tell the system HOW to do something**
* **Declarative → tell the system WHAT you want**

### Example

**Imperative:**

```bash
aws ec2 run-instances ...
```

You are basically saying:

> "Run this command and create an EC2 instance."

If you run it twice, you might create two instances.

**Declarative — Terraform:**

```hcl
resource "aws_instance" "web" {
  ami           = "ami-123"
  instance_type = "t3.micro"
}
```

You are saying:

> "I want an EC2 instance with these properties."

Terraform checks what already exists and determines what needs to change.

### Important term: Idempotency

* **Idempotent = running the same Terraform configuration repeatedly produces the same desired result.**
* If the EC2 instance already exists, Terraform doesn't create another one just because you run `apply` again.

### Simple example

```text
First apply:
Terraform → EC2 doesn't exist → CREATE EC2

Second apply:
Terraform → EC2 already exists → NO CHANGE

Third apply:
Terraform → EC2 already exists → NO CHANGE
```

### Why IaC?

Without IaC:

* Manual configuration is difficult to reproduce.
* Different environments can become different over time.
* Infrastructure changes are harder to track.
* Scaling requires more manual work.

With IaC:

* Infrastructure can be recreated.
* Changes can be tracked in Git.
* Environments can be consistent.
* Infrastructure can be created quickly.

### Example

Suppose you manually create:

```text
VPC
 ├── 2 Subnets
 ├── Internet Gateway
 ├── Route Table
 ├── Security Group
 └── EC2
```

Now your company wants the **same environment in another AWS region**.

Manual approach:

> Repeat all the steps.

Terraform:

> Use the same Terraform configuration with different variables.

### Exam takeaway

> **IaC manages infrastructure through machine-readable configuration instead of manual processes. Terraform is primarily declarative and idempotent.**

---

# 2. Advantages of IaC

You don't need to memorize a huge list. Understand these **six important benefits**.

## 2.1 Version Control

* Terraform files can be stored in Git.
* You can see:

  * Who changed infrastructure
  * What changed
  * When it changed
* You can review changes through Pull Requests.

### Example

Someone changes:

```hcl
ingress {
  from_port = 22
}
```

Git shows exactly what changed.

You can also revert the change.

### Remember

> **Infrastructure becomes version-controlled just like application code.**

---

## 2.2 Consistency

* The same Terraform code can create multiple environments.
* This reduces configuration drift.

### Example

You have:

```text
Development
Staging
Production
```

All are created from the same Terraform module.

Therefore, you don't depend on someone remembering:

> "I think production had this security group rule..."

### Remember

> **Same code → consistent infrastructure.**

---

## 2.3 Collaboration

Instead of:

```text
Engineer → AWS Console → Change something
```

you can have:

```text
Engineer
   ↓
Terraform code
   ↓
Git
   ↓
Pull Request
   ↓
Code Review
   ↓
Apply
```

This makes infrastructure changes easier to review.

---

## 2.4 Speed / Self-Service

Without IaC:

```text
Developer → Raise ticket
          ↓
       DevOps
          ↓
       Create EC2
          ↓
       Configure it
```

With Terraform:

```text
Developer
    ↓
terraform apply
    ↓
Environment created
```

### Remember

> IaC reduces manual operational work and can enable self-service infrastructure.

---

## 2.5 Cost Management

Terraform can create and destroy environments easily.

Example:

```bash
terraform apply
```

Create QA environment.

At night:

```bash
terraform destroy
```

Remove it.

Next morning:

```bash
terraform apply
```

Create it again.

Useful for temporary environments.

---

## 2.6 Documentation

Your Terraform code describes the infrastructure.

Instead of documentation saying:

> "Production has 3 EC2 instances."

Terraform actually defines:

```hcl
resource "aws_instance" "web" {
  count = 3
}
```

The code is much less likely to become stale than manually maintained documentation.

### Exam takeaway

The major IaC benefits to remember:

> **Version control + Consistency + Collaboration + Speed + Cost control + Documentation**

---

# 3. Terraform and Multi-Cloud

This is the important concept:

> **Terraform Core itself does not know how to create AWS, Azure, GCP, GitHub, etc. resources.**

Terraform uses **providers**.

### Think of it like this

```text
                Terraform Core
                     |
        +------------+------------+
        |            |            |
       AWS         Azure        GitHub
    Provider      Provider      Provider
        |            |            |
      AWS API      Azure API    GitHub API
```

### Terraform Core handles

* Reading Terraform configuration
* Building dependency graph
* Planning
* State management
* Deciding what needs to change

### Provider handles

> "How do I actually communicate with this platform?"

For example:

```text
Terraform
   ↓
AWS Provider
   ↓
AWS API
   ↓
EC2
```

---

# 4. What is a Provider?

A provider is essentially a **plugin that allows Terraform to communicate with a platform/service**.

Examples:

```text
hashicorp/aws
hashicorp/azurerm
hashicorp/google
hashicorp/kubernetes
integrations/github
```

### Example

```hcl
provider "aws" {
  region = "ap-south-1"
}
```

This tells Terraform:

> Use the AWS provider and work with the Mumbai region.

Then:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-123"
  instance_type = "t3.micro"
}
```

Terraform doesn't itself know how to call the EC2 API.

The AWS provider handles that.

---

# 5. Multi-Cloud Example

You can have multiple providers in the same Terraform project.

```text
Terraform
   |
   +---- AWS Provider
   |       ↓
   |      AWS
   |
   +---- GitHub Provider
           ↓
         GitHub
```

One Terraform configuration can therefore manage:

```text
AWS VPC
AWS EC2
GitHub Repository
Kubernetes Deployment
Vault configuration
```

### Example

```hcl
provider "aws" {
  region = "ap-south-1"
}

provider "github" {
  token = var.github_token
}
```

Then:

```hcl
resource "aws_instance" "web" {
  ...
}

resource "github_repository" "app" {
  ...
}
```

A single:

```bash
terraform apply
```

can manage both.

### Exam takeaway

> **Terraform is provider-based. Providers contain platform-specific knowledge. This is what allows Terraform to work across AWS, Azure, GCP, Kubernetes, GitHub, etc.**

---

# 6. Multiple AWS Accounts / Regions

You can also use the **same provider multiple times** with different configurations.

This is done using **provider aliases**.

Example:

```hcl
provider "aws" {
  alias  = "india"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"
}
```

Then a resource can specify which provider configuration to use:

```hcl
resource "aws_instance" "india_server" {
  provider = aws.india

  ...
}
```

Another:

```hcl
resource "aws_instance" "us_server" {
  provider = aws.us

  ...
}
```

### Think of it as

```text
              Terraform
                  |
          AWS Provider
           /         \
      aws.india     aws.us
          |            |
    ap-south-1      us-east-1
```

### Exam takeaway

> **Provider aliases allow multiple configurations of the same provider.**

---

# 7. Terraform Installation

This is mostly practical knowledge, so don't over-study it.

### Verify installation

```bash
terraform -version
```

### Important

Terraform is essentially a **CLI binary**.

You don't need to memorize every installation command for the exam.

Know:

> Terraform must be installed locally before you can run Terraform commands.

---

# 8. AWS Authentication

Terraform needs AWS credentials to communicate with AWS.

Two concepts are extremely important:

## Authentication

> **Who are you?**

Example:

```text
Access Key
Secret Key
```

AWS uses these credentials to identify you.

---

## Authorization

> **What are you allowed to do?**

IAM policies determine permissions.

Example:

```text
User:
terraform-deployer

Policy:
S3 ReadOnly
```

The credentials can be valid, but the user may not be allowed to create an EC2 instance.

---

## Very important distinction

```text
Authentication
      ↓
"Who are you?"
      ↓
Credentials valid?
      ↓
YES
      ↓
Authorization
      ↓
"What can you do?"
      ↓
IAM permissions
```

### Example

Terraform uses valid credentials:

```text
AWS recognizes user
        ↓
Authentication SUCCESS
        ↓
Try to create EC2
        ↓
IAM policy doesn't allow EC2
        ↓
Authorization FAILURE
```

### Exam takeaway

> **Authentication = identity. Authorization = permissions.**

---

# 9. AWS CLI Profile

Instead of putting AWS credentials directly inside Terraform code, you can use an AWS CLI profile.

Create one:

```bash
aws configure --profile terraform-dev
```

You provide:

```text
Access Key
Secret Key
Region
Output format
```

The profile is stored in:

```text
~/.aws/credentials
~/.aws/config
```

On Windows:

```text
C:\Users\<username>\.aws\credentials
C:\Users\<username>\.aws\config
```

Then Terraform can use it:

```hcl
provider "aws" {
  region  = "ap-south-1"
  profile = "terraform-dev"
}
```

### Why use profiles?

Suppose you have:

```text
[personal]
[terraform-dev]
[production]
```

You can select which credentials Terraform uses without putting secrets into `.tf` files.

### Remember

```text
Terraform
    ↓
profile = "terraform-dev"
    ↓
AWS CLI profile
    ↓
Credentials
    ↓
AWS
```

---

# 10. What happens if `profile` is not specified?

Terraform/AWS SDK can obtain credentials from other sources.

Common examples:

* Environment variables
* `AWS_PROFILE`
* Default AWS CLI profile
* IAM role credentials
* Other AWS-supported credential mechanisms

So:

```hcl
provider "aws" {
  region = "ap-south-1"
}
```

does **not** necessarily mean Terraform has no credentials.

It means:

> Terraform will use the AWS credential provider chain to find them.

---

# 11. Security — Never Hardcode Credentials

❌ Don't do this:

```hcl
provider "aws" {
  access_key = "AKIA..."
  secret_key = "SECRET..."
}
```

Why?

Your Terraform code might be committed to Git.

Then:

```text
Terraform code
      ↓
GitHub
      ↓
Credentials exposed
      ↓
Attacker
      ↓
AWS account
```

### Better approaches

For local development:

```text
AWS CLI profile
```

or environment variables.

For CI/CD:

```text
Temporary credentials
IAM roles
OIDC
```

### Important exam idea

> **Avoid long-lived credentials in Terraform code.**

---

# 12. Your First Terraform Resource

Basic example:

```hcl
provider "aws" {
  region  = "ap-south-1"
  profile = "terraform-dev"
}

resource "aws_instance" "web" {
  ami           = "ami-123"
  instance_type = "t3.micro"
}
```

Understand the resource syntax:

```text
resource "aws_instance" "web"
          │              │
          │              └── Local Terraform name
          └───────────────── Resource type
```

### `aws_instance`

Means:

> EC2 instance managed by the AWS provider.

### `web`

Just Terraform's local name for this resource.

You can reference it later as:

```text
aws_instance.web
```

---

# 13. `terraform init`

Run:

```bash
terraform init
```

### What does it do?

Mainly:

* Initializes the Terraform working directory.
* Downloads required providers.
* Creates/updates dependency information.

### Important

`terraform init` **does NOT create your EC2 instance.**

Think:

```text
terraform init
      ↓
Prepare Terraform
      ↓
Download provider
```

---

# 14. `terraform plan`

Run:

```bash
terraform plan
```

Terraform asks:

> "Based on the configuration and current infrastructure, what changes would I make?"

Example:

```text
+ aws_instance.web
```

`+` means:

> Create this resource.

### Important

`plan` does **not normally make the infrastructure change**.

It is your opportunity to review what Terraform intends to do.

---

# 15. `terraform apply`

Run:

```bash
terraform apply
```

Terraform:

```text
Read configuration
      ↓
Check state/current infrastructure
      ↓
Create execution plan
      ↓
Ask for confirmation
      ↓
Call provider
      ↓
AWS API
      ↓
EC2 created
```

### Remember

```text
init   → prepare
plan   → preview
apply  → execute
```

This is one of the most useful command relationships to remember.

---

# 16. `.terraform.lock.hcl`

This is the **provider dependency lock file**.

Think:

> "Which exact provider version should this project use?"

Example:

```hcl
provider "registry.terraform.io/hashicorp/aws" {
  version = "6.54.0"
}
```

### Why?

Suppose today:

```text
AWS provider = 6.54
```

Later:

```text
AWS provider = 6.60
```

You don't necessarily want everyone's environment to suddenly use a different version.

The lock file helps keep provider versions consistent.

### Important

✅ Commit `.terraform.lock.hcl` to Git.

---

# 17. `.terraform/`

This is Terraform's **local working directory**.

It contains things Terraform downloads/uses locally, including providers.

Example:

```text
.terraform/
    providers/
        ...
```

### Important

❌ Normally don't commit `.terraform/` to Git.

---

# 18. Provider Binary

Inside `.terraform` you may see something like:

```text
terraform-provider-aws_v6.54.0_x5
```

This is the actual AWS provider executable.

Think:

```text
Terraform CLI
      ↓
AWS Provider Plugin
      ↓
AWS API
```

Terraform Core doesn't contain all AWS-specific implementation details.

The provider does.

---

# 19. `.terraform.lock.hcl` vs `.terraform/`

This distinction is worth remembering:

| Item                  | Purpose                                 | Git?           |
| --------------------- | --------------------------------------- | -------------- |
| `.terraform.lock.hcl` | Locks provider version/checksums        | ✅ Commit       |
| `.terraform/`         | Local Terraform working files/providers | ❌ Don't commit |

---

# 20. Terraform State — Just Enough for Domain 1

Don't go deep into state yet; that's the next domain.

For now understand:

After:

```bash
terraform apply
```

Terraform keeps information about the resources it manages in:

```text
terraform.tfstate
```

For example:

```text
Terraform state
      ↓
"I created EC2 instance i-123456"
```

Later, Terraform can compare:

```text
Terraform configuration
        VS
Terraform state / real infrastructure
```

and determine what needs to change.

### Why this matters for idempotency

First apply:

```text
No EC2
  ↓
Create EC2
  ↓
State records it
```

Second apply:

```text
Terraform sees EC2 already exists
  ↓
No duplicate EC2
```

We'll go much deeper into state in Domain 2.

---

# 21. The Complete Mental Model

If you remember only one diagram from Domain 1, remember this:

```text
                  main.tf
                     |
                     ↓
              Terraform Core
                     |
             Reads configuration
                     |
             Builds execution plan
                     |
                     ↓
              Provider Plugin
                     |
                     ↓
                 AWS API
                     |
                     ↓
              AWS Resources
```

And credentials are used along the way:

```text
Terraform
    ↓
AWS Provider
    ↓
AWS Credentials/Profile
    ↓
AWS Authentication
    ↓
IAM Authorization
    ↓
AWS API
```

---

# 22. Commands You Actually Need to Remember

| Command              | Meaning                                            |
| -------------------- | -------------------------------------------------- |
| `terraform init`     | Initialize directory / download providers          |
| `terraform plan`     | Preview changes                                    |
| `terraform apply`    | Apply changes                                      |
| `terraform destroy`  | Destroy managed infrastructure                     |
| `terraform validate` | Check Terraform configuration syntax/configuration |

### Easy memory trick

```text
INIT → PLAN → APPLY → DESTROY
```

---

# 23. Exam-Level Scenarios

### Scenario 1

You run Terraform `apply` twice. Will Terraform create two EC2 instances?

**No.**

Because Terraform is declarative and uses state to determine what already exists.

---

### Scenario 2

Terraform has valid AWS credentials but receives:

```text
UnauthorizedOperation
```

What is wrong?

**Authorization.**

The identity was authenticated successfully, but its IAM permissions don't allow the operation.

---

### Scenario 3

Terraform needs to create an EC2 instance. Does Terraform Core directly know how to call the EC2 API?

**No.**

The **AWS provider** handles AWS-specific API interaction.

---

### Scenario 4

You want Terraform to manage AWS and GitHub resources.

Do you need two separate Terraform projects?

**Not necessarily.**

You can use:

```text
AWS provider
GitHub provider
```

in the same Terraform configuration.

---

### Scenario 5

You run:

```bash
terraform init
```

Will an EC2 instance be created?

**No.**

`init` prepares Terraform and downloads providers.

---

### Scenario 6

You accidentally commit AWS credentials to Git.

What's the problem?

The credentials may be exposed, allowing someone to authenticate to AWS.

**Never hardcode credentials in Terraform code.**

---

# 24. Domain 1 — What You Should Actually Remember

If you're preparing for the Terraform Associate exam, I'd reduce the entire domain to this:

### IaC

* Infrastructure managed through code.
* Terraform is primarily **declarative**.
* Declarative = define **desired state**.
* Terraform is **idempotent**.

### Benefits

* Version control
* Consistency
* Collaboration
* Automation/self-service
* Reproducibility
* Cost control

### Terraform Architecture

* **Terraform Core** → planning, state, dependency graph
* **Provider** → communicates with specific platform/API
* AWS → AWS provider
* GitHub → GitHub provider
* Kubernetes → Kubernetes provider

### Multi-cloud

* Multiple providers can exist in one Terraform configuration.
* Provider aliases allow multiple configurations of the same provider.

### AWS Authentication

* **Authentication = Who are you?**
* **Authorization = What can you do?**
* IAM policies control authorization.
* Prefer profiles/temporary credentials rather than hardcoded credentials.

### Important files

```text
main.tf
    ↓
Terraform configuration

.terraform.lock.hcl
    ↓
Provider version/checksum lock
    ↓
COMMIT

.terraform/
    ↓
Local working directory/providers
    ↓
DON'T COMMIT

terraform.tfstate
    ↓
Terraform's record of managed infrastructure
    ↓
State is covered deeply in Domain 2
```

### Core commands

```text
terraform init
      ↓
terraform plan
      ↓
terraform apply
      ↓
terraform destroy
```

---

This is the style I recommend for **all your remaining Terraform notes**: **short theory + bullet-point explanation + practical example + exam takeaway**, rather than explaining every concept from multiple angles. The uploaded notes cover these Domain 1 objectives and setup topics. 
