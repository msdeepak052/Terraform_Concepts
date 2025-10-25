# 🌍 **Terraform 2025 Mastery Roadmap**

> 🎓 *Goal:* Master Terraform from zero to pro in 12 weeks — aligned with **HashiCorp Terraform Associate (003)** & real-world DevOps projects.

---

## 🗓️ **Week 1 — Introduction & Foundations 🧱**

### 🔍 Key Concepts

* **Infrastructure as Code (IaC)** — What, why & benefits:

  * ✅ Version-controlled infrastructure
  * ✅ Repeatable deployments
  * ✅ Automated provisioning
* **Terraform Basics** — Open-source by HashiCorp, declarative syntax (HCL), multi-cloud capable.
* **Terraform CLI Installation** — On Windows, macOS, or Linux.
* **Your First Terraform Run:** Learn `init`, `plan`, `apply`, `destroy`.

### 🧩 Example

```hcl
terraform {
  required_version = ">= 1.0"
}
provider "aws" {
  region = "ap-south-1"
}
resource "aws_instance" "example" {
  ami           = "ami-xxxxxxx"
  instance_type = "t2.micro"
}
```

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

### 🧠 Practice

* Use your AWS/Azure/GCP free-tier.
* Observe how Terraform tracks infra via `.tfstate`.
* Commit `main.tf` to GitHub for version control.

---

## ⚙️ **Week 2 — Core Workflow & State Concepts 🔄**

### 🔍 Key Concepts

* **Terraform Workflow:**
  `init` → `plan` → `apply` → `destroy`
* **Providers, Resources, Data Sources**
* **State File:**

  * `terraform.tfstate` = Source of truth for infrastructure.
  * Learn what happens when you modify or delete resources manually.

### 🧩 Example

```hcl
output "instance_ip" {
  value = aws_instance.example.public_ip
}
```

➡️ Try changing instance type → re-run `plan` → see the diff!

### 🧠 Practice

* Add a **Security Group** resource and link it.
* Delete a resource manually → run `plan` → observe drift.
* Use `terraform show` to explore state file contents.

---

## 🧮 **Week 3 — Variables, Outputs, & Expressions 💡**

### 🔍 Key Concepts

* **Input Variables:** Types, defaults, validations
* **Outputs:** Sharing resource data
* **Functions & Interpolation:**
  `upper()`, `concat()`, `length()` etc.
* **Terraform built-in functions**
* **Conditionals & Loops**
    * count
    * for_each
    * for expressions
    * if expressions
* **Data Types:** string, number, list, map, object

### 🧩 Example

```hcl
variable "allowed_ports" {
  type    = list(number)
  default = [22, 80]
}

resource "aws_security_group" "sg" {
  name_prefix = "demo-sg"
  ingress = [
    for port in var.allowed_ports : {
      from_port   = port
      to_port     = port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
```

### 🧠 Practice

* Use `count` for multiple instances.
* Use `for_each` for maps of subnets.
* Try combining string interpolation with logic (`condition ? value1 : value2`).

---

## 🧭 **Week 4 — State, Backends & Workspaces 🌐**

### 🔍 Key Concepts

* **State:** Tracks deployed infra. Learn about corruption, locking, and recovery.
* **Backends:**

  * Local (default)
  * Remote (S3 + DynamoDB, Terraform Cloud)
* **Workspaces:** Separate state files for `dev`, `staging`, `prod`.

### 🧩 Example

```hcl
terraform {
  backend "s3" {
    bucket         = "my-tfstate-bucket"
    key            = "infra/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tf-lock"
  }
}
```

```bash
terraform workspace new dev
terraform workspace list
terraform workspace select prod
```

### 🧠 Practice

* Create S3 backend + DynamoDB lock table.
* Deploy to different workspaces (dev/prod).
* Test drift: modify resource manually → `terraform plan`.

---

## 🧩 **Week 5 — Modules & Code Reuse 🧱**

### 🔍 Key Concepts

* **Modules:** Reusable Terraform code blocks.
* **Sources:** Local, Git, Registry.
* **Inputs/Outputs:** Parameterize your modules.
* **Structure:**

  ```
  modules/
  ├── ec2_instance/
  │   ├── main.tf
  │   ├── variables.tf
  │   └── outputs.tf
  ```

### 🧩 Example

```hcl
module "web_server" {
  source        = "./modules/ec2_instance"
  instance_type = var.instance_type
  ami           = var.ami
}
```

### 🧠 Practice

* Convert your old configs into modules (network, compute, security).
* Try a public module from the [Terraform Registry](https://registry.terraform.io/).

---

## ⚡ **Week 6 — Provisioners, Dependencies & Lifecycle ⚙️**

### 🔍 Key Concepts

* **Meta-arguments:**

  * `count`, `for_each`, `depends_on`, `lifecycle`
* **Provisioners:** `local-exec`, `remote-exec` (use sparingly).
* **Lifecycle:** Control creation & destruction behavior.

### 🧩 Example

```hcl
resource "aws_instance" "app" {
  ami = "ami-xxxx"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }

  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install -y nginx"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file(var.private_key_path)
    }
  }
}
```

### 🧠 Practice

* Add `depends_on` between subnet and EC2.
* Simulate accidental destruction → apply lifecycle safeguard.

---

## 🧠 **Week 7 — Dynamic Blocks & Advanced Expressions 🔁**

### 🔍 Key Concepts

* **Dynamic Blocks:** Create nested structures dynamically.
* **Complex Variables:** Lists, maps, objects of objects.
* **Terraform Console:** Test expressions interactively.

### 🧩 Example

```hcl
dynamic "ingress" {
  for_each = var.ports
  content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

```bash
terraform console
> [for p in var.ports : "port-${p}"]
```

### 🧠 Practice

* Use dynamic blocks for optional tags or ingress rules.
* Build nested maps & iterate using `for` expressions.

---

## 🧭 **Week 8 — Terraform Cloud & Remote State Data ☁️**

### 🔍 Key Concepts

* **terraform_remote_state:** Share outputs between configs.
* **Terraform Cloud Workflows:** Workspaces, policy enforcement, team runs.
* **State Sharing:** Safely use data between environments.

### 🧩 Example

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "tf-bucket"
    key    = "network/terraform.tfstate"
    region = "ap-south-1"
  }
}
```

### 🧠 Practice

* Link your `network` and `compute` projects.
* Try Terraform Cloud free-tier + GitHub repo integration.

---

## ☁️ **Week 9 — Multi-Cloud & Provider Versioning 🌍**

### 🔍 Key Concepts

* Multiple providers (AWS, Azure, GCP).
* Provider aliasing (`provider = aws.us_east`).
* Provider & module version constraints.

### 🧩 Example

```hcl
provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "ap_south"
  region = "ap-south-1"
}
```

### 🧠 Practice

* Deploy one instance in two regions.
* Experiment with provider version upgrade & lock file (`.terraform.lock.hcl`).

---

## 🔒 **Week 10 — Validation, Testing & Security 🧹**

### 🔍 Key Concepts

* `terraform validate`, `fmt`, and `plan -detailed-exitcode`.
* **Linting:** `tflint`, `tfsec`, `checkov`.
* **Secrets Management:** Avoid hardcoded credentials.

### 🧩 Example

```bash
terraform validate
terraform fmt -check
tflint --init && tflint
```

### 🧠 Practice

* Build CI job to auto-validate Terraform code.
* Use `data "aws_ami"` instead of static AMI.

---

## 🧱 **Week 11 — Real-World Architectures 🏗️**

### 🔍 Key Concepts

* Build **3-tier infrastructure:**
  VPC → EC2 → RDS
* **Refactoring:** Split monolithic code into modules.
* **Import:** Manage existing infra under Terraform.

### 🧩 Example

```bash
terraform import aws_vpc.main vpc-0abc123
```

### 🧠 Practice

* Build your **banking app** infra using modules (network, app, db).
* Refactor earlier configs → add versioned modules.

---

## 🚀 **Week 12 — CI/CD, Governance & Exam Prep 🎯**

### 🔍 Key Concepts

* **CI/CD Pipelines:** Plan on PR, Apply on merge (GitHub Actions/Jenkins).
* **Governance:** Sentinel / OPA for policy enforcement.
* **Exam Prep:** Review objectives for HashiCorp Certified Terraform Associate (003).

### 🧩 Example

GitHub Actions Workflow 👇

```yaml
name: Terraform CI
on: [pull_request]
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v3
      - run: terraform init && terraform validate && terraform plan
```

### 🧠 Practice

* Create CI workflow for your repo.
* Add tagging policy enforcement (`tfsec`).
* Take a Terraform mock exam before scheduling the official one.

---

## 🧭 **Pro Tip Zone for Deepak**

💡 *Because you’re already experienced with DevOps:*

* Fast-track Week 1–2; deep-dive into modules, workspaces & CI/CD.
* Maintain a GitHub repo named `terraform-labs-2025` to document weekly progress.
* Each week → push one **hands-on project folder** (with README).
* Follow [Terraform Changelog](https://github.com/hashicorp/terraform/releases) for new features like `moved` blocks & import blocks (v1.5+).

---
