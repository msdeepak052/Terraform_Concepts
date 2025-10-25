# Terraform 2025

## **Week 1: Introduction & Foundations**

### Concepts

* Infrastructure as Code (IaC): what it is, benefits (versioning, repeatability, automation) and how Terraform fits. ([whizlabs.com][1])
* What is Terraform: open-source tool by HashiCorp, declarative language HCL, multi-cloud/provider-agnostic. ([Wikipedia][2])
* Installing Terraform CLI & initial configuration (on your machine).
* First simple configuration: define a provider (e.g., AWS, Azure) and one resource (e.g., an EC2 or VM) just to run `terraform init`, `terraform plan`, `terraform apply`, `terraform destroy`.

### Example

* Create a file `main.tf` with:

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
* Commands:

  ```bash
  terraform init
  terraform plan
  terraform apply  # approve
  terraform destroy
  ```
* Observe what each command does: init sets up backend/plugins; plan shows what will change; apply makes changes; destroy cleans up.

### Practice

* Use free-tier account on AWS/Azure/GCP (your choice) and run this sample.
* Version control the `main.tf` in Git (you’ve used Git in projects before) to track changes.

---

## **Week 2: Terraform Workflow & Core Commands**

### Concepts

* Workflow: `init`, `plan`, `apply`, `destroy`. Understand what each phase means. ([CyberPanel][3])
* Understand providers, resources, data sources.
* Understand Terraform configuration files: `.tf` files, modules (later), variables, outputs.
* State management: default local state file (`terraform.tfstate`), how Terraform knows what’s deployed. Basic concept.

### Example

* Modify your previous config: add output to show the public IP:

  ```hcl
  output "instance_ip" {
    value = aws_instance.example.public_ip
  }
  ```
* Run `terraform apply` and then view the output.
* Change a property (e.g., `instance_type = "t2.small"`), run `terraform plan`, see difference, then apply.

### Practice

* Experiment: add a second resource (maybe a security group) and link it.
* Destroy and recreate; note how state changes.
* Try to change something outside Terraform (e.g., manually change security group in console) and see what happens when `terraform plan` runs (drift).

---

## **Week 3: Variables, Outputs, Interpolation & Expressions**

### Concepts

* Variables: input variables (type, default, description), how to reference them.
* Outputs: how to expose values.
* Interpolation: string interpolation, using expressions, functions (e.g., `length`, `upper`, `concat`) in HCL.
* Data types: string, number, bool, list, map, object.
* Expressions: conditions, for_each loops, count meta-argument basics.

### Example

* Define variables:

  ```hcl
  variable "instance_type" {
    type    = string
    default = "t2.micro"
  }
  variable "allowed_ports" {
    type    = list(number)
    default = [22,80]
  }
  ```
* Use them:

  ```hcl
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
* Output map of allowed ports:

  ```hcl
  output "ports_list" {
    value = var.allowed_ports
  }
  ```

### Practice

* Add variables for region, instance type, number of instances (use `count`).
* Use `for_each` to create multiple similar resources (e.g., multiple instances).
* Try writing expressions using functions on lists/maps.

---

## **Week 4: State, Backends & Workspaces**

### Concepts

* State: what it is, why it matters (tracks current infrastructure). Risks if state is stale/corrupt.
* Backends: Local backend vs remote backends (e.g., S3+DynamoDB for locking, Terraform Cloud). Best practices for team/shared environments.
* Workspaces: concept of multiple workspaces per configuration (e.g., dev/test/prod), isolation of state.
* State locking, state drift, state import.

### Example

* Configure a remote backend (e.g., AWS S3 + DynamoDB) for state:

  ```hcl
  terraform {
    backend "s3" {
      bucket         = "my-tfstate-bucket"
      key            = "terraform.tfstate"
      region         = "ap-south-1"
      dynamodb_table = "tfstate-lock"
    }
  }
  ```
* Create workspaces: `terraform workspace new dev`, `terraform workspace list`, `terraform workspace select dev`.
* Switch to another workspace `prod`, run apply, observe separate state.

### Practice

* Setup S3 + DynamoDB backend (if you have AWS free-tier) for your config.
* Practice switching between workspaces and deploy different configurations for dev/test.
* Simulate manual change: manually change a resource in AWS console; run `terraform plan` to see drift. Discuss how to reconcile (e.g., `terraform import`).

---

## **Week 5: Modules & Code Organization**

### Concepts

* What are modules: reusable Terraform configurations; best practices (small, single-purpose modules).
* Module sources: local paths, Git repository, Terraform Registry.
* Inputs & outputs of modules; versioning modules.
* Organizing code: root module vs child modules, directory structure.
* Module versioning and re-usability.

### Example

* Create a module `modules/ec2_instance` containing `main.tf`, `variables.tf`, `outputs.tf` to create an EC2.
  Root module calls:

  ```hcl
  module "web_server" {
    source        = "./modules/ec2_instance"
    instance_type = var.instance_type
    ami           = var.ami
  }
  ```
* In `modules/ec2_instance/variables.tf`: define variables. In `outputs.tf`: output instance ID and IP.

### Practice

* Refactor your Week 1/2/3 config into modules: e.g., module for network (VPC + subnets), module for compute (instances) etc.
* Publish a module (locally) and reuse it twice (for web and app tier).
* Experiment with using a module from Terraform Registry (e.g., community AWS VPC module) in your config.

---

## **Week 6: Provisioners, Meta-Arguments, Lifecycle & Dependencies**

### Concepts

* Meta-arguments: `count`, `for_each`, `depends_on`, `lifecycle` (create_before_destroy, prevent_destroy, ignore_changes).
* Provisioners: `local-exec`, `remote-exec` — when to use (with caution). Best practice is minimal use. ([Medium][4])
* Dependencies and resource ordering.
* Resource targeting: `-target` option in `terraform plan/apply`. Importing resources.

### Example

* Example of `lifecycle`:

  ```hcl
  resource "aws_instance" "example" {
    # ...  
    lifecycle {
      create_before_destroy = true
      prevent_destroy       = false
      ignore_changes        = [ "user_data" ]
    }
  }
  ```
* Example `remote-exec` provisioner:

  ```hcl
  resource "aws_instance" "app" {
    # ...
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

### Practice

* Use `count` or `for_each` to create multiple subnets or instances.
* Use `lifecycle` meta-argument to avoid accidental destruction of important resources.
* Try provisioning a simple script on the instance via `remote-exec`. Then refactor to remove provisioner and instead use a configuration management tool externally (and discuss why provisioners are less recommended).

---

## **Week 7: Advanced Expressions & Functions, Dynamic Blocks**

### Concepts

* Deep dive into functions: strings, collections, numeric, filesystem if available.
* Complex types: objects, maps of objects, lists of objects.
* `dynamic` blocks: for when you need nested blocks generated by iteration.
* Conditionals and ternary operators.
* Using `terraform console` to evaluate expressions interactively. ([More than Certified][5])

### Example

* Example `dynamic` block:

  ```hcl
  resource "aws_security_group" "sg" {
    name_prefix = "dyn-sg"
    dynamic "ingress" {
      for_each = var.ports
      content {
        from_port   = ingress.value
        to_port     = ingress.value
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
  }
  ```
* Using `terraform console`:

  ```bash
  terraform console
  > length(var.allowed_ports)
  > upper("hello")
  > [ for p in var.allowed_ports : "port-${p}" ]
  ```

### Practice

* Write a resource that allows optional tags: if `var.tags` is nonempty, use dynamic to add tags.
* Use complex types: variable `servers = list(object({ name = string, size = string }))` and iterate to create multiple instances.
* Explore the built-in functions list and try 5 functions you haven't used yet.

---

## **Week 8: Remote State Data & Terraform Cloud / Team Workflows**

### Concepts

* Remote state data sources: `terraform_remote_state` to pull outputs from another state to reuse data across modules/configs.
* Team workflows: collaboration, using version control (Git) with Terraform configs, code reviews, policy as code.
* Terraform Cloud / Enterprise: workspaces, runs, state management, private module registry, policies (Sentinel), remote operations. ([HashiCorp Developer][6])
* State locking & state consistency in team environments.

### Example

* Use `terraform_remote_state` to reference output of a VPC config from another workspace:

  ```hcl
  data "terraform_remote_state" "network" {
    backend = "s3"
    config = { bucket = "...", key = "network/terraform.tfstate", region = "ap-south-1" }
  }

  resource "aws_instance" "web" {
    subnet_id = data.terraform_remote_state.network.outputs.public_subnet_id
    # ...
  }
  ```
* Workflow: develop feature branch, run Terraform plan in CI, apply after merge.
* Explore Terraform Cloud: create workspace, connect GitHub repo, trigger plan & apply.

### Practice

* Create two separate Terraform projects: one for network (VPC/subnets) and one for compute (instances). Use remote state to connect them.
* If you have access, set up Terraform Cloud (free tier) and connect your repo; explore run results, variables in workspace.

---

## **Week 9: Multi-Cloud, Providers & Provider Versioning**

### Concepts

* Provider ecosystem: AWS, Azure, GCP, and many others (GitHub, Kubernetes, etc.). Understanding provider configuration, aliasing providers for multi-region/account scenarios. ([HashiCorp Developer][7])
* Version constraints for providers and modules using `required_providers` & `version`.
* Multi-cloud scenarios: e.g., provision some resources in AWS, others in Azure, with single Terraform project.
* Provider authentication methods (credentials, environment variables, IAM roles, service principals).

### Example

* Example of aliasing providers:

  ```hcl
  provider "aws" {
    alias  = "us_east"
    region = "us-east-1"
  }

  provider "aws" {
    alias  = "ap_south"
    region = "ap-south-1"
  }

  resource "aws_instance" "east" {
    provider = aws.us_east
    # ...
  }

  resource "aws_instance" "india" {
    provider = aws.ap_south
    # ...
  }
  ```
* Version constraints:

  ```hcl
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 4.0"
      }
    }
  }
  ```

### Practice

* Pick a second cloud provider (if you have free credits, say Azure) and provision a simple resource there (VM) using Terraform.
* Use alias provider to target two regions/accounts in the same config (e.g., AWS us-east and ap-south).
* Fix provider version and experiment with upgrading provider and see if any breaking changes.

---

## **Week 10: Testing, Validation, Linting & Best Practices**

### Concepts

* Code quality: use of `terraform validate`, `terraform fmt`, `terraform fmt -check`, `terraform plan` as gate.
* Linting with tools like `tflint`, `checkov`, `tfsec`.
* Writing tests: e.g., using `terraform plan` exit code, `terratest` (Go) or `kitchen-terraform`.
* Best practices: module design, naming conventions, variable defaults, avoiding secrets in code, state security, remote backend locking.
* Security & drift concerns: awareness of sustainability & security “smells” in IaC. ([arXiv][8])

### Example

* Run `terraform validate` in the root directory; fix any warnings.
* Install `tflint` and run: `tflint --init && tflint`. Fix any lint issues (unused variables, naming).
* Use `terraform fmt` to reformat files.
* Example best practice: do not hard-code AMI IDs; use data source to lookup latest AMI per region.

### Practice

* Add tests or checks: write a small script or CI job that runs `terraform fmt -check`, `terraform validate`, `terraform plan -detailed-exitcode` and fails if plan would change.
* Configure `.gitignore` for Terraform state files and use remote state.
* Review your modules and refactor any that violate best practices (e.g., too large, too many responsibilities).

---

## **Week 11: Complex Architectures, Refactoring & Real-World Projects**

### Concepts

* Building more complex infrastructure: e.g., three-tier architecture (since you’re working on banking app) with VPC, public/private subnets, NAT gateways, load balancers, auto-scaling groups.
* Refactoring existing code: DRY (Don’t Repeat Yourself), splitting modules, promoting reusability, versioning modules.
* Handling environment promotions: dev → test → prod; using workspaces or separate root modules.
* Importing existing resources (`terraform import`), handling drift and legacy infra.

### Example

* Suppose you want to create three-tier architecture:

  * Module `network` for VPC + subnets + NAT + Internet Gateway
  * Module `compute` for app servers + load balancer
  * Module `database` for RDS/MSSQL in private subnets
* Use `terraform import aws_vpc.my_vpc vpc-1234567` to bring an existing VPC under Terraform control.
* Refactor: move networking code out of root into `modules/network`, adjust root to call it.

### Practice

* Model your three-tier banking app infrastructure using Terraform modules. Sketch architecture, then code it.
* Practice importing at least one existing resource (maybe a security group) and manage it via Terraform.
* Refactor an existing Terraform config you wrote earlier (from Week 1-3) into modules, separate files, improve readability and modularity.

---

## **Week 12: CI/CD Integration, Monitoring, Governance & Next Steps**

### Concepts

* Integrating Terraform into CI/CD pipelines: plan on PRs, apply on merge, infrastructure automation.
* Monitoring and managing infrastructure lifecycle: e.g., Terraform Enterprise features, drift detection.
* Governance, policy as code: Define rules (cost guardrails, naming conventions, tag enforcement) — e.g., via Sentinel in Terraform Cloud or Open Policy Agent.
* Exam preparation & certification path: HashiCorp Certified: Terraform Associate (003) (for foundations) and then HashiCorp Certified: Terraform Authoring & Operations Professional (advanced) if you want. ([HashiCorp Developer][6])
* Keeping up-to-date: Terraform versions, provider updates, best practices in 2025.

### Example

* Set up GitHub Actions (or Jenkins) to run:

  ```yaml
  name: Terraform CI
  on:
    pull_request:
      paths:
        - "terraform/**"
  jobs:
    plan:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v2
        - name: Setup Terraform
          uses: hashicorp/setup-terraform@v1
          with:
            terraform_version: 1.5.0
        - name: Terraform Init
          run: terraform init
        - name: Terraform Format Check
          run: terraform fmt -check
        - name: Terraform Validate
          run: terraform validate
        - name: Terraform Plan
          run: terraform plan -out=tfplan
        - name: Upload plan artifact
          uses: actions/upload-artifact@v2
          with:
            name: tfplan
            path: tfplan
  ```
* Example policy: ensure every resource has a `tags` attribute with `Environment` and `Owner`.

### Practice

* Implement in your banking app project the CI pipeline for Terraform code.
* Write at least one policy to enforce naming convention or prohibit open security groups (`0.0.0.0/0`).
* Review your full 12-week codebase: ensure modularity, best practices, documentation, version control.
* If you’re ready, schedule the Terraform Associate (003) exam and take a mock test.

---

## Additional Notes & Tips for Deepak

* Because you already have DevOps/cloud experience, you may accelerate some weeks or deep-dive more in those you find challenging (modules, CI/CD, governance).
* Make sure to **practice hands-on** — Terraform is best learned by doing.
* Use your existing cloud accounts (AWS, Azure) that you’re familiar with; as you know DevOps workflows, you’ll link Terraform with your pipelines, source control etc.
* Since you prefer step-by-step learning, treat each week as a mini-milestone: at the end of each week write a short summary of what you learnt and commit a code sample to your GitHub repository.
* Keep an eye on **Terraform version updates** (for example v1.x) and provider changes — the ecosystem evolves in 2025. ([DEV Community][9])
* Align your study with the official exam objectives for Associate and Professional levels. ([HashiCorp Developer][6])

---

If you like, I can **extend this roadmap to 24 weeks**, including deeper topics such as advanced module patterns, multi-team workflows, organizational scale, migrations (Terraform 0.x → 1.x), cloud-native IaC integration (e.g., Kubernetes, Helm provider), and even real-world project templates tailored for your three-tier banking app. Do you want that extended version?

[1]: https://www.whizlabs.com/blog/hashicorp-terraform-associate-certification/?utm_source=chatgpt.com "[New] HashiCorp Terraform Associate Certification Guide - Whizlabs"
[2]: https://en.wikipedia.org/wiki/Terraform_%28software%29?utm_source=chatgpt.com "Terraform (software)"
[3]: https://cyberpanel.net/blog/terraform-certification?utm_source=chatgpt.com "Terraform Certification | HashiCorp Associate Exam Guide"
[4]: https://medium.com/%40muhamedayman7/terraform-associate-003-experience-2025-ef0a213a4449?utm_source=chatgpt.com "Terraform Associate 003 Experience 2025 - Medium"
[5]: https://morethancertified.com/course/mtc-terraform?utm_source=chatgpt.com "More than Certified in Terraform 2025"
[6]: https://developer.hashicorp.com/terraform/tutorials/pro-cert/pro-study?utm_source=chatgpt.com "Learning Path - Terraform Authoring and Operations Pro with AWS"
[7]: https://developer.hashicorp.com/terraform/tutorials/certification-003/associate-study-003?utm_source=chatgpt.com "Learning Path - Terraform Associate (003) - HashiCorp Developer"
[8]: https://arxiv.org/abs/2501.07676?utm_source=chatgpt.com "Smells-sus: Sustainability Smells in IaC"
[9]: https://dev.to/devopsking/the-ultimate-terraform-tutorial-from-beginner-to-advanced-2024-guide-3n1o?utm_source=chatgpt.com "The Ultimate Terraform Tutorial: From Beginner to Advanced (2025 ..."
