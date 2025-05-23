# 📦 Terraform Modules: Enterprise Guide

## ✅ What is a Terraform Module?

A **module** is a container for multiple resources that are used together. A module can be:

- **Local** (within your repo/project)
- **Remote** (hosted on GitHub, Bitbucket, Terraform Registry, etc.)

### 🔑 Benefits of Using Modules

- ✅ Code reusability  
- 📁 Better organization  
- 🧪 Easier testing and versioning  
- 👥 Team collaboration with clear interfaces (inputs/outputs)

---

## 🔧 Basic Structure

```bash
main.tf         # Declares resources  
variables.tf    # Input variables  
outputs.tf      # Output values  

```
### You can use this module from another Terraform configuration like so:

## ✅ Usage Example

``` hcl

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
}
```

# Terraform Modules for Enterprise Infrastructure

You can use this module from another Terraform configuration like so:

```hcl
module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
}
```

# 💼 Real Enterprise Examples – Terraform Modules

---

## 1. Networking Module – VPC Provisioning in AWS

### Use Case
A fintech company needs multiple environments (dev, staging, prod), each with its own isolated VPC.

### 🔨 Module Path
`modules/network/vpc/`

### Terraform Code

```hcl
# modules/network/vpc/main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

output "vpc_id" {
  value = aws_vpc.main.id
}

```

### Usage:

```hcl

module "prod_vpc" {
  source     = "../modules/network/vpc"
  cidr_block = "10.1.0.0/16"
}

```


### ➡️ Benefits:

- DevOps team reuses this across environments.

- Changes to VPC logic only happen in one place.

### 2. Kubernetes Cluster Module with EKS
- Use Case: A health-tech startup runs workloads on EKS with autoscaling, IAM roles, and node groups.

### 🔨 Module Path: modules/eks/

```hcl

# modules/eks/main.tf
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"
  subnets         = var.subnet_ids
  vpc_id          = var.vpc_id

  node_groups = {
    default = {
      desired_capacity = 3
      max_capacity     = 5
      min_capacity     = 1

      instance_types = ["t3.medium"]
    }
  }
}
```
### ➡️ Benefits:

- Use of remote modules from Terraform Registry.

- Abstracts away complexity from DevOps engineers.

### 3. CI/CD Integration – GitHub Actions IAM Role Module
Use Case: A media company needs to give CI/CD pipelines temporary permissions to deploy infrastructure.

### 🔨 Module Path: modules/iam/ci_cd_role/

```hcl

resource "aws_iam_role" "ci_cd" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "github-actions.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

```
### Usage:

``` hcl

module "ci_cd_role" {
  source    = "../modules/iam/ci_cd_role"
  role_name = "github-actions-deploy-role"
}

``` 
### ➡️ Benefits:

- Security & access management is modular.

- Reused by multiple app pipelines.

### 4. Multi-Cloud Strategy – Azure + AWS Networking Modules
Use Case: An enterprise migrating from Azure to AWS creates reusable modules for both platforms.



# modules/azure/vnet/
# modules/aws/vpc/
### Conditional Usage Example:

```hcl
module "network" {
  source = var.cloud == "aws" ? "../modules/aws/vpc" : "../modules/azure/vnet"
  ...
}
```
### ⚙️ Tips for Writing Great Modules
Use variables.tf and outputs.tf cleanly

- Version-lock modules when using remote sources

- Document every module with a README.md

- Use terraform-docs to auto-generate documentation

- Follow naming conventions and set lifecycle policies (e.g., prevent_destroy)

- Use depends_on sparingly to avoid tight coupling

### 🎯 Final Thoughts
- In enterprise environments, modular Terraform is a non-negotiable practice. It:

- Simplifies complex infrastructure

- Enables team collaboration

- Aligns with GitOps & CI/CD workflows

- Supports scalability across environments and cloud providers
