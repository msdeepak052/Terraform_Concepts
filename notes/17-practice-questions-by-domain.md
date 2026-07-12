# Practice Questions — Organized by Exam Domain

This file reorganizes all 57 scenarios from [16-practice-questions-with-answers.md](16-practice-questions-with-answers.md) by the **same 8 official exam domains** used in files [01](01-domain1-iac-concepts.md)–[10](10-domain8-hcp-terraform.md), then by difficulty tier within each domain. It's a navigation index only — full requirements, worked HCL answers, and the "Industry Best-Practice Notes" callouts all still live in file 16; look up the section + question number listed here to find the full write-up.

**Difficulty tiers** map directly to file 16's own five sections:
- **Beginner or Easy** ← the "Beginner-Level Scenarios" section
- **Intermediate** ← the "Intermediate-Level Scenarios" section
- **Hard** ← "Advanced-Level Scenarios," "Module-Focused Practice," and "Real-World Industry Scenarios" combined (all three are advanced-tier content in the original file)

**Domain classification is best-fit.** Several scenarios genuinely touch two or three domains (e.g. a module that also uses `depends_on`, or a state topic that also involves provider aliasing) — each is filed under the domain its *dominant, most-distinctive* Terraform mechanism belongs to, with a short reason noted wherever that call isn't obvious. Where a question sits in Domain 4 (which spans files 4a/4b/4c), the sub-file is tagged inline.

**Domains 1 and 2 are conceptual/light domains in this bank** — most of file 16's scenarios are hands-on HCL/AWS exercises, so they naturally cluster into Domains 3–8. Domains 1 and 2 each already have their own dedicated Easy/Medium/Hard practice questions at the end of [01-domain1-iac-concepts.md](01-domain1-iac-concepts.md) and [02-domain2-terraform-fundamentals.md](02-domain2-terraform-fundamentals.md) — use those for that material instead.

---

## Domain 1 — IaC Concepts

No dedicated scenarios from this bank map here — this domain is conceptual (what IaC is, its benefits, IaC vs. manual/imperative approaches) rather than a hands-on HCL skill, so file 16's scenario-driven questions don't naturally test it. See the practice questions at the end of [01-domain1-iac-concepts.md](01-domain1-iac-concepts.md).

---

## Domain 2 — Terraform Fundamentals

**Beginner or Easy** — none

**Intermediate** — none

**Hard**
- **Advanced Q10** — Multiple AWS Profiles/Regions *(provider aliasing is core Terraform-fundamentals material — see the dedicated aliasing section added to file 02)*
- **Real-World Q16** — Use Terraform to Provision Azure/AWS Hybrid Infrastructure *(multi-provider/multi-cloud is a "what Terraform fundamentally is" concept, not a language or module mechanic)*

---

## Domain 3 — Core Workflow

**Beginner or Easy**
- **Beginner Q6** — Destroy Specific Resources *(`-target`, targeting)*
- **Beginner Q7** — Terraform Formatting and Validation *(`fmt` / `validate` / `plan`)*

**Intermediate** — none

**Hard**
- **Advanced Q4** — Terraform CI/CD Integration (GitHub Actions / GitLab CI)
- **Real-World Q3** — Set Up Terraform CI/CD in GitHub Actions *(same core-workflow commands, automated)*

---

## Domain 4 — Configuration Language (4a/4b/4c)

**Beginner or Easy**
- **Beginner Q1** — Provision a Single EC2 Instance *(4a — variables, provider/resource blocks)*
- **Beginner Q2** — Create a VPC with a Public Subnet *(4b — `for_each` over a subnet list)*
- **Beginner Q3** — Use Input Variables *(4a)*
- **Beginner Q4** — Define and Use Output Variables *(4a)*
- **Beginner Q5** — Create a Simple Security Group *(4b — per-rule `for_each`)*

**Intermediate**
- **Intermediate Q5** — Conditionally Create Resources *(4b — `count`/`for_each` conditionals)*
- **Intermediate Q6** — Use Data Sources to Reference AMIs *(4a — `data` blocks)*
- **Intermediate Q7** — Pass Variables Using `terraform.tfvars` *(4a — precedence order)*
- **Intermediate Q8** — Define Multiple Security Groups Dynamically *(4b — `for_each` + `flatten`)*
- **Intermediate Q10** — Provision Multiple EC2 Instances Using `for_each` *(4b)*

**Hard**
- **Advanced Q2** — Use Dynamic Blocks for Security Group Rules *(4b — `dynamic` blocks)*
- **Advanced Q5** — Use `locals` and Complex Data Structures *(4b)*
- **Advanced Q9** — Handle Resource Dependencies with `depends_on` *(4c — explicit dependencies)*
- **Real-World Q1** — Launch a Scalable Web Application *(4a)*
- **Real-World Q5** — Manage IAM Roles and Policies *(4a)*
- **Real-World Q7** — Deploy a Serverless Application Using Lambda and API Gateway *(4a)*
- **Real-World Q11** — Manage Secrets with AWS SSM or Secrets Manager *(4c — ephemeral/write-only, sensitive data)*
- **Real-World Q12** — Scheduled Auto Start/Stop of EC2 Instances *(4a)*
- **Real-World Q13** — Monitor Infrastructure with CloudWatch Dashboards *(4b — `jsonencode` function)*
- **Real-World Q15** — Automate SSL Certificate Management *(4c — implicit dependency / wait-resource pattern)*
- **Real-World Q18** — Create an Audit-Ready Logging and Monitoring Setup *(4a)*
- **Real-World Q20** — Implement Cost Optimization with Auto Scaling and Spot Instances *(4a)*

---

## Domain 5 — Modules

**Beginner or Easy** — none

**Intermediate**
- **Intermediate Q1** — Create a Reusable VPC Module
- **Intermediate Q2** — Deploy EC2 Instances in a Private Subnet with a NAT Gateway *(structured as a `vpc` + `ec2` module pair; also touches 4c `depends_on`)*

**Hard**
- **Advanced Q1** — Build a Multi-Tier Architecture Using Modules
- **Advanced Q6** — Create and Manage an EKS Cluster *(registry module usage)*
- **Advanced Q7** — Use a Remote Module from GitHub
- **Module-Focused Q1** — Module for EC2 with Custom Security Group
- **Module-Focused Q2** — Nested Module Usage
- **Module-Focused Q3** — Parameterize Resource Count in a Module
- **Module-Focused Q4** — Write a Module for S3 Bucket Creation
- **Module-Focused Q5** — Module with Conditional Logic
- **Module-Focused Q6** — Module for CloudWatch Alarms
- **Module-Focused Q7** — DRY Modules for Multi-Tier Architecture
- **Module-Focused Q8** — Use of `locals` in Modules
- **Module-Focused Q9** — Output Propagation from Modules
- **Module-Focused Q10** — Use Public Modules (Terraform Registry or GitHub)
- **Real-World Q2** — Deploy a Multi-Tier Architecture
- **Real-World Q6** — Provision an EKS Cluster with Worker Nodes

*(This is the largest domain bucket after Configuration Language, since the entire "Module-Focused Practice" section from file 16 lands here wholesale.)*

---

## Domain 6 — State Management

**Beginner or Easy** — none

**Intermediate**
- **Intermediate Q3** — Use Remote State with S3 and DynamoDB (and the modern S3-native-locking alternative)
- **Intermediate Q4** — Use Workspaces for Environment Isolation

**Hard**
- **Advanced Q3** — Split Configuration into Multiple Files and Environments *(per-environment state isolation)*
- **Real-World Q4** — Terraform with Remote State in S3 and State Locking in DynamoDB *(same topic as Intermediate Q3, real-world framing)*
- **Real-World Q8** — Blue/Green Deployment Using Terraform Workspaces
- **Real-World Q19** — Onboard New Environments with a Single Command *(per-environment state; also the Terragrunt-bonus capstone)*

---

## Domain 7 — Maintain Infrastructure

**Beginner or Easy** — none

**Intermediate**
- **Intermediate Q9** — Import Existing Resources *(`terraform import` / `import` block)*

**Hard**
- **Advanced Q8** — Terraform State Management: Move/Remove Resources *(`state mv`/`rm`, `-replace` — Domain 7's "state CLI" scope)*
- **Real-World Q9** — Provision a Multi-Region Disaster Recovery Setup *(`terraform_remote_state` data source)*
- **Real-World Q17** — Import Legacy Resources to Terraform *(same topic as Intermediate Q9, real-world framing)*

---

## Domain 8 — HCP Terraform

**Beginner or Easy** — none

**Intermediate** — none

**Hard**
- **Real-World Q10** — Infrastructure Tagging Strategy *(the graded content is Sentinel/OPA policy enforcement, not the `default_tags` syntax itself)*
- **Real-World Q14** — Use Sentinel or OPA for Policy-as-Code

---

## Summary Table

| Domain | Beginner/Easy | Intermediate | Hard | Total |
|---|---|---|---|---|
| 1 — IaC Concepts | 0 | 0 | 0 | 0 |
| 2 — Terraform Fundamentals | 0 | 0 | 2 | 2 |
| 3 — Core Workflow | 2 | 0 | 2 | 4 |
| 4 — Configuration Language | 5 | 5 | 12 | 22 |
| 5 — Modules | 0 | 2 | 15 | 17 |
| 6 — State Management | 0 | 2 | 4 | 6 |
| 7 — Maintain Infrastructure | 0 | 1 | 3 | 4 |
| 8 — HCP Terraform | 0 | 0 | 2 | 2 |
| **Total** | **7** | **10** | **40** | **57** |
