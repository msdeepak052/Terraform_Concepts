# Q7 — Screenshots

Visual walkthrough of workspace-based environment isolation — `dev`, `staging`, and `prod` workspaces sharing one codebase, each driven by its own `.tfvars` file. Concept, caveats, and full step-by-step are in [guide.md](guide.md).

### 1. Backend Init

`terraform init -reconfigure -backend-config="key=Terraform_Practise/16.Practise_Sets/Q7"`

```
Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
```

<!-- paste screenshot of terraform init output here -->

---

### 2. Creating the Workspaces

```
$ terraform workspace show
default

$ terraform workspace new dev
Created and switched to workspace "dev"!

$ terraform workspace new staging
Created and switched to workspace "staging"!

$ terraform workspace new prod
Created and switched to workspace "prod"!

$ terraform workspace list
  default
  dev
* prod
  staging
```

<!-- paste screenshot of workspace new / workspace list output here -->

---

### 3. Plan — Same Code, Different Workspace, Different `.tfvars`

| Workspace | `.tfvars` | `instance_type` | Instances | `Environment` tag |
|---|---|---|---|---|
| `dev`     | `dev.tfvars`     | `t2.micro`  | 1 | `dev`     |
| `staging` | `staging.tfvars` | `t2.small`  | 1 | `staging` |
| `prod`    | `prod.tfvars`    | `t2.medium` | 2 | `prod`    |

**dev plan** (`terraform plan -var-file="dev.tfvars"`) → `Plan: 1 to add, 0 to change, 0 to destroy.`

<!-- paste screenshot of dev plan output here -->

**staging plan** (`terraform plan -var-file="staging.tfvars"`) → `Plan: 1 to add, 0 to change, 0 to destroy.`

<!-- paste screenshot of staging plan output here -->

**prod plan** (`terraform plan -var-file="prod.tfvars"`) → `Plan: 2 to add, 0 to change, 0 to destroy.` (note `instance_count = 2` → `q7-prod-app-1` and `q7-prod-app-2`)

<!-- paste screenshot of prod plan output here -->

---

### 4. Apply — `dev` Workspace

```
$ terraform workspace select dev
$ terraform apply -var-file="dev.tfvars"
...
aws_instance.app[0]: Creation complete after 12s [id=i-073186c4ea6da993b]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

<!-- paste screenshot of terraform apply output here -->

---

### 5. AWS Console — EC2 Instance(s) Per Environment

<!-- paste screenshot of dev instance (q7-dev-app-1, t2.micro) in EC2 console here -->

<!-- paste screenshot of staging instance (q7-staging-app-1, t2.small) in EC2 console here, after applying staging -->

<!-- paste screenshot of prod instances (q7-prod-app-1, q7-prod-app-2, t2.medium) in EC2 console here, after applying prod -->

---

### 6. Tags — Confirming `terraform.workspace` Drove the `Environment` Tag

<!-- paste screenshot of the EC2 instance's Tags tab showing Environment = dev / staging / prod here -->

---

### 7. State Isolation in S3

`aws s3 ls s3://terraform-practise-backend-deepak/env:/ --recursive` (or browse the bucket in the AWS Console)

Expect one state object per workspace, each under its own `env:/<workspace>/` prefix:

```
env:/dev/Terraform_Practise/16.Practise_Sets/Q7
env:/staging/Terraform_Practise/16.Practise_Sets/Q7
env:/prod/Terraform_Practise/16.Practise_Sets/Q7
```

<!-- paste screenshot of the S3 bucket showing the separate env:/ state paths here -->

---

### 8. Destroy / Cleanup

```
$ terraform workspace select dev
$ terraform destroy -var-file="dev.tfvars"

$ terraform workspace select staging
$ terraform destroy -var-file="staging.tfvars"

$ terraform workspace select prod
$ terraform destroy -var-file="prod.tfvars"

$ terraform workspace select default
$ terraform workspace delete dev
$ terraform workspace delete staging
$ terraform workspace delete prod
```

<!-- paste screenshot of destroy output here -->
