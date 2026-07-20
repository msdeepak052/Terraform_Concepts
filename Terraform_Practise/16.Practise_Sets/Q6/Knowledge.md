Yes. **This is exactly how it is done in production.** You never let the EC2 module know how the VPC was built. The VPC module exposes outputs, and the EC2 module only consumes those outputs. This is Terraform's recommended module pattern. ([HashiCorp Developer][1])

---

# Real-life Project Structure

```
root
│
├── main.tf
├── variables.tf
├── terraform.tfvars
│
└── modules
    ├── vpc
    │    ├── main.tf
    │    ├── variables.tf
    │    └── outputs.tf
    │
    └── ec2
         ├── main.tf
         ├── variables.tf
         └── outputs.tf
```

---

# Step 1 - VPC module creates everything

Inside the VPC module

```
VPC
├── Public Subnet A
├── Public Subnet B
├── Private Subnet A
├── Private Subnet B
├── IGW
├── NAT Gateway
├── Route Tables
└── Associations
```

Suppose you created private subnets like this

```
resource "aws_subnet" "subnets" {
    for_each = {
       private-a = ...
       private-b = ...
       public-a  = ...
       public-b  = ...
    }
}
```

---

# Step 2 - Output the subnet IDs

**outputs.tf**

```
output "private_subnet_ids" {
  value = [
    for name, subnet in aws_subnet.subnets :
    subnet.id
    if can(regex("private", name))
  ]
}
```

Suppose Terraform creates

```
private-a -> subnet-11111

private-b -> subnet-22222
```

Output becomes

```
module.vpc.private_subnet_ids

=

[
   "subnet-11111",
   "subnet-22222"
]
```

This is exactly what Terraform modules are meant to expose. ([HashiCorp Developer][1])

---

# Step 3 - EC2 module

The EC2 module **doesn't know anything** about VPC resources.

It simply expects

```
variable "subnet_id" {
    type = string
}
```

Inside

```
resource "aws_instance" "ec2" {

    subnet_id = var.subnet_id

}
```

Notice

The EC2 module doesn't know

* VPC
* Route table
* NAT
* Internet Gateway

It only knows

> "Give me a subnet ID."

This makes the module reusable.

---

# Step 4 - Root module connects both modules

```
module "vpc" {

    source = "./modules/vpc"

}
```

Now call EC2

```
module "ec2" {

    source = "./modules/ec2"

    subnet_id = module.vpc.private_subnet_ids[0]

}
```

Flow becomes

```
VPC Module

creates

Private subnet

↓

Outputs

[
 subnet-11111,
 subnet-22222
]

↓

Root module

↓

EC2 Module

↓

Launch instance inside subnet-11111
```

Exactly this pattern is shown in HashiCorp examples where resources consume subnet outputs from a VPC module. ([HashiCorp Developer][2])

---

# But what if I don't know which subnet?

In production this is common.

Instead of

```
private_subnet_ids[0]
```

companies usually make it configurable.

Example

```
variable "private_subnet_index" {

    default = 0

}
```

```
module "ec2" {

    subnet_id =
    module.vpc.private_subnet_ids[var.private_subnet_index]

}
```

Then

```
0
```

means

```
private-a
```

and

```
1
```

means

```
private-b
```

---

# Even Better Production Approach

Most large organizations avoid using list indexes because the order of subnets can change as environments evolve. Instead, they output a **map** keyed by subnet name.

VPC output:

```
output "private_subnet_ids" {

  value = {
      for name, subnet in aws_subnet.subnets :
      name => subnet.id
      if can(regex("private", name))
  }

}
```

Output becomes

```
{
   private-a = subnet-11111
   private-b = subnet-22222
}
```

Now the root module becomes

```
module "ec2" {

    subnet_id =
    module.vpc.private_subnet_ids["private-a"]

}
```

Why is this better?

Imagine tomorrow you add

```
private-c
```

The map becomes

```
{
   private-a = subnet-11111
   private-b = subnet-22222
   private-c = subnet-33333
}
```

Your EC2 still uses

```
private-a
```

Nothing changes.

With a list, adding or removing subnets can shift indexes and affect downstream references. Many experienced Terraform users recommend maps keyed by subnet name for this reason. ([Reddit][3])

---

# Complete Production Flow

```
                 Root Module
                      │
      ┌───────────────┴───────────────┐
      │                               │
      ▼                               ▼
  VPC Module                    EC2 Module
      │                               ▲
      │                               │
Creates                        subnet_id input
VPC
Public Subnets
Private Subnets
IGW
NAT
Route Tables
      │
      ▼
Outputs

private_subnet_ids = {
    private-a = subnet-11111
    private-b = subnet-22222
}

      │
      ▼

module.vpc.private_subnet_ids["private-a"]

      │
      ▼

EC2 launches in subnet-11111
```

## What do companies typically do?

For production-grade reusable modules:

* The **VPC module** creates networking resources and outputs values like `vpc_id`, `private_subnet_ids`, and `public_subnet_ids`.
* The **EC2 module** accepts only the inputs it needs (`subnet_id`, `security_group_ids`, IAM profile, etc.).
* The **root module** wires modules together by passing `module.vpc.private_subnet_ids["private-a"]` (or another selected subnet) into the EC2 module.
* Prefer **maps keyed by subnet name** over list indexes for long-lived infrastructure, because they are more stable as environments change.

[1]: https://developer.hashicorp.com/terraform/language/values/outputs?utm_source=chatgpt.com "Use outputs to expose module data | Terraform | HashiCorp Developer"
[2]: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-manage?utm_source=chatgpt.com "Manage infrastructure | Terraform | HashiCorp Developer"
[3]: https://www.reddit.com/r/Terraform/comments/w91ynr?utm_source=chatgpt.com "Best Practice for Child Module Outputs"

---

Excellent question. This is actually something many engineers wonder when they first start designing reusable Terraform modules.

The short answer is:

**Terraform itself does not perform load balancing or intelligent subnet selection.** It is a declarative IaC tool, not a scheduler.

Let's see how this is handled in real production environments.

---

# Option 1: Always use subnet[0] ❌ (Not recommended)

```hcl
subnet_id = module.vpc.private_subnet_ids[0]
```

Every EC2 goes into

```
Private-A
```

Eventually

```
Private-A
10.0.1.0/24

250 EC2s

Private-B
10.0.2.0/24

5 EC2s
```

Very bad utilization.

---

# Option 2: Choose manually

```hcl
subnet_id = module.vpc.private_subnet_ids["private-b"]
```

The platform engineer decides.

This is common for standalone infrastructure like:

* Bastion hosts
* Jenkins
* GitLab runners
* Monitoring servers

because there are usually only a few instances.

---

# Option 3: Use modulo (very common in Terraform)

Suppose you're creating multiple EC2s.

```hcl
variable "instance_count" {
  default = 6
}
```

```hcl
resource "aws_instance" "this" {
  count = var.instance_count

  subnet_id = module.vpc.private_subnet_ids[
    count.index % length(module.vpc.private_subnet_ids)
  ]
}
```

Terraform distributes them like this:

| EC2   | count.index | Subnet    |
| ----- | ----------: | --------- |
| ec2-1 |           0 | private-a |
| ec2-2 |           1 | private-b |
| ec2-3 |           2 | private-a |
| ec2-4 |           3 | private-b |
| ec2-5 |           4 | private-a |
| ec2-6 |           5 | private-b |

This is a common pattern when creating a known set of instances.

---

# Option 4: Auto Scaling Group (Most common in production)

This is what large companies use.

Instead of launching EC2s directly, you create an Auto Scaling Group.

```hcl
vpc_zone_identifier = module.vpc.private_subnet_ids
```

Notice that you pass **all** private subnet IDs.

AWS decides where each instance goes.

```
Private-A

EC2
EC2
EC2

Private-B

EC2
EC2
EC2
```

AWS spreads instances across Availability Zones and attempts to balance them. If one subnet becomes constrained, scaling may place instances in the other eligible subnet, subject to capacity and your configuration.

This is the standard approach for:

* Web servers
* Microservices
* Kubernetes worker nodes
* Application servers

---

# Option 5: EKS (Most modern production platforms)

When you create an EKS managed node group, you specify all eligible private subnets.

```hcl
subnet_ids = module.vpc.private_subnet_ids
```

AWS provisions worker nodes across those subnets.

Then the Kubernetes scheduler places pods on the worker nodes.

```
Private-A

Node-1
Node-3

Private-B

Node-2
Node-4
```

You don't choose the subnet for each node manually.

---

# Option 6: Service Discovery / Dynamic Placement

Some internal platform teams build logic that:

* Queries available IPs in subnets.
* Chooses the subnet with the most free addresses.
* Passes that subnet ID into Terraform.

This is typically implemented by external orchestration or an internal platform API, **not by Terraform itself**.

---

# Can Terraform detect which subnet has more free IPs?

Not in a practical way.

Terraform can read some existing AWS resources through data sources, but it doesn't act as a scheduler that evaluates subnet utilization and picks the "best" subnet for new instances. Any such decision logic is usually handled outside Terraform.

---

# What do big companies actually do?

It depends on the workload:

| Workload                              | Typical approach                                                                    |
| ------------------------------------- | ----------------------------------------------------------------------------------- |
| Single EC2 (bastion, Jenkins, GitLab) | Choose a specific subnet intentionally.                                             |
| Multiple EC2s created together        | Round-robin using modulo or explicit assignment.                                    |
| Application servers                   | Auto Scaling Group with all private subnets.                                        |
| Kubernetes (EKS)                      | Pass all private subnets to the node group.                                         |
| Large internal platforms              | An external scheduler or platform service selects the subnet before Terraform runs. |

### For your Platform Engineer role

Since you're working with **AWS, EKS, Terraform, and platform engineering**, the production patterns you'll encounter most are:

* **ASGs**: pass all private subnets and let AWS distribute instances.
* **EKS managed node groups**: pass all private subnets.
* **Standalone infrastructure (jump hosts, CI/CD servers, monitoring, etc.)**: choose a designated subnet, because there are relatively few instances and IP exhaustion is rarely an issue if the VPC is properly designed.

The key idea is that **Terraform describes the desired infrastructure**, while **AWS services (like ASG and EKS)** or higher-level platform automation are responsible for intelligent placement and balancing.


---

Yes, you **can build such a solution**, but there's an important distinction:

* ✅ **Possible** by calling AWS APIs (or using an external script/Lambda).
* ❌ **Not recommended** to embed directly into Terraform because it breaks Terraform's declarative model and can make plans non-deterministic.

If you're building an **internal platform** for your company, however, this can be a very good idea.

---

# Goal

Suppose you have:

```
Private-A   10.0.1.0/24

Available IPs = 180


Private-B   10.0.2.0/24

Available IPs = 70


Private-C   10.0.3.0/24

Available IPs = 240
```

Instead of

```hcl
subnet_id = module.vpc.private_subnet_ids[0]
```

you want

```
Terraform

↓

Call AWS API

↓

Find subnet with maximum free IPs

↓

Return subnet-xxxxxxxx

↓

Launch EC2 there
```

---

# AWS already exposes the information

The `DescribeSubnets` API returns a field named:

```
AvailableIpAddressCount
```

Example response:

```json
{
  "SubnetId": "subnet-1111",
  "AvailabilityZone": "ap-south-1a",
  "AvailableIpAddressCount": 180
}
```

For another subnet:

```json
{
  "SubnetId": "subnet-2222",
  "AvailableIpAddressCount": 70
}
```

So AWS already gives you exactly what you need.

---

# Logic

Pseudo-code:

```python
subnets = describe_subnets()

best = max(
    subnets,
    key=lambda s: s["AvailableIpAddressCount"]
)

return best["SubnetId"]
```

---

# Terraform Integration (using `external` data source)

One approach is to have Terraform call a script:

```hcl
data "external" "best_subnet" {
  program = [
    "python",
    "${path.module}/choose_subnet.py"
  ]
}
```

Then:

```hcl
resource "aws_instance" "ec2" {

  subnet_id = data.external.best_subnet.result.subnet_id

}
```

---

# Python Script

Example:

```python
import boto3
import json

ec2 = boto3.client("ec2")

response = ec2.describe_subnets(
    Filters=[
        {
            "Name": "tag:Tier",
            "Values": ["Private"]
        }
    ]
)

best = max(
    response["Subnets"],
    key=lambda x: x["AvailableIpAddressCount"]
)

print(json.dumps({
    "subnet_id": best["SubnetId"]
}))
```

Terraform receives

```
{
  "subnet_id": "subnet-0ab12345"
}
```

and launches the EC2 there.

---

# Better Production Logic

Don't always choose the subnet with the most free IPs.

Imagine:

```
Subnet A : 251 free

Subnet B : 250 free

Subnet C : 5 free
```

If every deployment picks **Subnet A**, you'll quickly drain it while **Subnet B** stays almost untouched.

A smarter strategy is:

1. Filter eligible private subnets.
2. Ignore subnets below a minimum free-IP threshold (for example, 20).
3. Sort by available IPs.
4. Select one of the top N subnets (or use weighted random selection based on free IPs).

Example:

```
A = 251
B = 250
C = 5
```

Eligible:

```
A
B
```

Random choice:

```
Run 1 → A
Run 2 → B
Run 3 → A
Run 4 → B
```

This avoids a "hot" subnet.

---

# An Enterprise Architecture

In larger organizations, the flow often looks like:

```
Terraform
      │
      ▼
Platform API
      │
      ▼
AWS DescribeSubnets
      │
      ▼
Find private subnets
      │
      ▼
Read AvailableIpAddressCount
      │
      ▼
Apply placement policy
      │
      ▼
Return subnet_id
      │
      ▼
Terraform launches EC2
```

This keeps the placement logic centralized and reusable.

---

# Would I recommend this?

For **production platform engineering**, yes—but **not as Terraform business logic**.

A better design is:

* Create a small **placement service** (Lambda, API Gateway + Lambda, or an internal service).
* It queries `DescribeSubnets`.
* It applies your placement policy (capacity, AZ balancing, reserved headroom, etc.).
* It returns the chosen subnet ID.
* Terraform (or your CI/CD pipeline) consumes that result.

This separates **infrastructure definition** (Terraform) from **placement decisions** (your platform), which is easier to test, evolve, and reuse.

So the idea itself is sound and is similar to what sophisticated internal platforms do, but I would avoid embedding complex scheduling logic directly into Terraform. Instead, make Terraform consume the result of a dedicated placement component.

---

Exactly. In production, **hardcoding `user_data = file("${path.module}/userdata/httpd_install.sh")` inside the module is not considered a reusable design.**

Your EC2 module should **not know** whether it's launching:

* Apache server
* Nginx server
* Jenkins
* Docker host
* Bastion
* SonarQube
* GitLab Runner

That decision belongs to the **root module**.

---

# Production Design

## EC2 Module

### variables.tf

```hcl
variable "user_data" {
  description = "User data script content"
  type        = string
  default     = null
}
```

---

### main.tf

```hcl
resource "aws_instance" "web" {

  count = var.instance_count

  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [var.security_group_id_web]

  user_data = var.user_data

  tags = merge(
    var.tags,
    {
      Name = "deepak-web-instance-${count.index + 1}"
    }
  )
}
```

Notice the EC2 module has **no idea where the script came from**.

---

# Folder Structure

```
project/

├── main.tf
├── terraform.tfvars
├── userdata/
│     ├── apache.sh
│     ├── nginx.sh
│     ├── jenkins.sh
│     └── docker.sh
│
└── modules
      └── ec2
           ├── main.tf
           ├── variables.tf
           └── outputs.tf
```

The scripts live in the **root**, not inside the reusable module.

---

# Root Module

Suppose you want Apache.

```hcl
module "web_server" {

  source = "./modules/ec2"

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id = module.vpc.private_subnet_ids["private-a"]

  security_group_id_web = module.sg.web_security_group_id

  user_data = file("${path.root}/userdata/apache.sh")

  tags = local.common_tags
}
```

Tomorrow you want Jenkins.

Just change one line:

```hcl
user_data = file("${path.root}/userdata/jenkins.sh")
```

No changes to the EC2 module.

---

# Even Better (Production)

Instead of using `file()`, use `templatefile()`.

Suppose your script needs variables.

`userdata/apache.sh.tpl`

```bash
#!/bin/bash

dnf install httpd -y

systemctl enable httpd

echo "Welcome to ${hostname}" > /var/www/html/index.html

systemctl start httpd
```

Root module:

```hcl
user_data = templatefile(
  "${path.root}/userdata/apache.sh.tpl",
  {
    hostname = "Production-Web-01"
  }
)
```

Now the script becomes dynamic.

---

# Real Company Example

Imagine one reusable EC2 module.

Different teams can use it like this:

### Team A

```hcl
user_data = file("${path.root}/userdata/apache.sh")
```

### Team B

```hcl
user_data = file("${path.root}/userdata/docker.sh")
```

### Team C

```hcl
user_data = file("${path.root}/userdata/jenkins.sh")
```

### Team D

```hcl
user_data = null
```

The **same EC2 module** works for all of them.

---

## My recommendation

For production-grade reusable modules:

* Keep `user_data` as an **input variable** (`string`, default `null`).
* Pass the script from the **root module** using `file()` or, preferably, `templatefile()` if the script needs variables.
* Keep application-specific bootstrap scripts **outside** the reusable EC2 module.

This is the pattern you'll commonly see in well-designed Terraform modules because it keeps the module generic and reusable.

---
### **using `for_each` at the module level** is a very common production pattern when you want to create multiple Security Groups from the same reusable module.

Instead of:

```hcl
module "web_sg" { ... }

module "db_sg" { ... }

module "bastion_sg" { ... }

module "jenkins_sg" { ... }
```

you can do this.

---

## variables.tf (Root)

```hcl
variable "security_groups" {
  type = map(object({
    description   = string
    ingress_rules = list(object({
      name      = string
      from_port = number
      to_port   = number
      protocol  = string
      cidr      = string
    }))
    egress_rules = list(object({
      name        = string
      protocol    = string
      cidr        = string
      description = string
    }))
  }))
}
```

---

## terraform.tfvars

```hcl
security_groups = {
  web = {
    description = "Web Security Group"

    ingress_rules = [
      {
        name      = "http"
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr      = "0.0.0.0/0"
      }
    ]

    egress_rules = [
      {
        name        = "all"
        protocol    = "-1"
        cidr        = "0.0.0.0/0"
        description = "Allow all"
      }
    ]
  }

  db = {
    description = "Database Security Group"

    ingress_rules = [
      {
        name      = "mysql"
        from_port = 3306
        to_port   = 3306
        protocol  = "tcp"
        cidr      = "10.0.0.0/16"
      }
    ]

    egress_rules = [
      {
        name        = "all"
        protocol    = "-1"
        cidr        = "0.0.0.0/0"
        description = "Allow all"
      }
    ]
  }
}
```

---

## Root `main.tf`

```hcl
module "security_groups" {

  source = "./modules/sg"

  for_each = var.security_groups

  name          = each.key
  description   = each.value.description
  vpc_id        = module.vpc.vpc_id
  ingress_rules = each.value.ingress_rules
  egress_rules  = each.value.egress_rules
  tags          = local.common_tags
}
```

Terraform creates:

```
module.security_groups["web"]
module.security_groups["db"]
```

Each module instance creates one Security Group.

---

## Outputs

Since your module outputs:

```hcl
output "security_group_id" {
  value = aws_security_group.this.id
}
```

you can access them like this:

```hcl
module.security_groups["web"].security_group_id

module.security_groups["db"].security_group_id
```

---

## Pass them to the EC2 module

For a web server:

```hcl
module "web_ec2" {
  source = "./modules/ec2"

  security_group_ids = [
    module.security_groups["web"].security_group_id
  ]
}
```

Or attach multiple:

```hcl
security_group_ids = [
  module.security_groups["web"].security_group_id,
  module.security_groups["ssm"].security_group_id,
  module.security_groups["monitoring"].security_group_id
]
```

---

## Is this how companies do it?

Yes. There are two common patterns:

1. **A few well-known security groups** (web, db, bastion): separate module blocks are often used because they're explicit and easy to read.

2. **Platform or landing-zone modules** that may create many security groups: `for_each` at the module level is very common because it scales without duplicating configuration.

For a reusable infrastructure library, your `for_each` approach is an excellent design. It keeps the security group module generic while allowing the root module to define as many security groups as needed.
