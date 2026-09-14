# Bonus — Terraform Challenges, Exam Booking & Final Exam Prep

This section is less about learning a new Terraform feature and more about **bringing everything together**, preparing for the exam, and testing whether you can choose the right Terraform concept when given a scenario.

---

# 1. Terraform Challenges — What Are They Actually For?

The four challenges are designed to make you **combine concepts from different domains** rather than practice each Terraform feature separately.

The pattern is:

```text
Challenge
   ↓
Understand requirements
   ↓
Try yourself
   ↓
Use hints only if stuck
   ↓
Check solution
   ↓
Understand WHY that approach was chosen
```

The important skill isn't:

> "Can I copy the solution?"

It's:

> **"Given a requirement, can I identify which Terraform feature should solve it?"**

That is much closer to what the exam tests.

---

# 2. How You Should Attempt the Challenges

## Step 1 — Read the entire requirement first

Don't start coding immediately.

Look for requirements such as:

```text
Create 3 instances
Use these tags
Use a variable for region
Create only when enabled
Use a specific output
```

A challenge can fail even when the Terraform syntax is correct if you missed one requirement.

---

## Step 2 — Attempt the entire challenge yourself

Don't immediately open the solution.

It's okay to get stuck.

In fact, getting stuck is useful because it forces you to ask:

> "Which Terraform concept should I use here?"

---

## Step 3 — Use hints only when necessary

Hints should help you move forward without giving you the complete answer.

---

## Step 4 — Compare your solution with the official solution

Don't only compare:

```text
"My code ≠ their code"
```

Instead compare:

```text
Did I choose the correct Terraform concepts?
```

For example, perhaps the solution uses:

```hcl
for_each
```

while you used:

```hcl
count
```

Your implementation may still work, but you should understand **why `for_each` might be a better choice**.

Different Terraform code can produce the same correct result.

---

# 3. What Each Challenge Focuses On

| Challenge       | Main concepts                                            |
| --------------- | -------------------------------------------------------- |
| **Challenge 1** | Resources, variables, outputs                            |
| **Challenge 2** | Multiple resources, dependencies, `for_each`, references |
| **Challenge 3** | Functions, locals, conditionals, dynamic blocks          |
| **Challenge 4** | Modules, state, multi-tier architecture                  |

Think of them as increasing in difficulty:

```text
Challenge 1
    ↓
Basic Terraform
    ↓
Challenge 2
    ↓
Dependencies + collections
    ↓
Challenge 3
    ↓
Expressions + dynamic configuration
    ↓
Challenge 4
    ↓
Modules + architecture + state
```

---

# 4. Challenge 1 — Fundamentals

Challenge 1 is primarily about the basics:

```text
Resources
Variables
Outputs
```

For example:

```hcl
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
}

output "instance_id" {
  value = aws_instance.web.id
}
```

The goal isn't to build a complicated architecture.

It's to make sure you are comfortable with:

```text
Input
  ↓
Variable
  ↓
Resource
  ↓
Output
```

---

# 5. Challenge 2 — Dependencies and `for_each`

This challenge moves into relationships between resources.

You may need:

```hcl
for_each
```

and resource references such as:

```hcl
aws_instance.web.id
```

Terraform can automatically detect dependencies when one resource references another.

For example:

```hcl
resource "aws_eip" "web" {
  instance = aws_instance.web.id
}
```

Terraform understands:

```text
EC2
 ↓
EIP
```

This is an **implicit dependency**.

If there is a dependency Terraform cannot infer from an attribute reference, you may need:

```hcl
depends_on = [...]
```

That's an **explicit dependency**.

---

# 6. Challenge 3 — Expressions

Challenge 3 focuses heavily on Terraform's expression language.

You should be comfortable with:

### Functions

```hcl
length(var.instances)
```

### Conditionals

```hcl
var.environment == "prod" ? "large" : "small"
```

### Locals

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"
}
```

### Dynamic blocks

```hcl
dynamic "ingress" {
  for_each = var.rules

  content {
    from_port = ingress.value.from_port
    to_port   = ingress.value.to_port
  }
}
```

The important skill is choosing the right tool:

```text
Need calculation/transformation?
        ↓
Function

Need reusable calculated value?
        ↓
Local

Need if/else?
        ↓
Conditional

Need repeated nested block?
        ↓
Dynamic block
```

---

# 7. Challenge 4 — Capstone

Challenge 4 brings together the major concepts:

* Modules
* State
* Dependencies
* Multiple resources
* Multi-tier architecture

Before writing code, you should first think about the resource graph.

For example:

```text
VPC
 │
 ├── Public Subnet
 │       ↓
 │    Load Balancer
 │
 └── Private Subnet
         ↓
      Application
```

Then decide:

```text
What should be a module?
What are the inputs?
What are the outputs?
What belongs in the same state?
What resources depend on others?
```

This is much closer to real Terraform work than simply remembering syntax.

---

# 8. Why You Shouldn't Skip Straight to Solutions

If you watch the solution first, you may think:

> "Yeah, that makes sense."

But that's **recognition**, not problem-solving.

The exam frequently gives you a situation like:

> "You need multiple named resources and want their identities to remain stable when one item is removed. Which Terraform feature should you use?"

You need to independently reach:

```text
for_each
```

rather than recognize it after someone has already shown it.

So the challenge should be:

```text
Requirement
    ↓
Your reasoning
    ↓
Terraform feature
    ↓
Implementation
```

That reasoning process is the real value of the challenges. 

---

# 9. Exam Format

According to the course notes, the exam is:

* **60 minutes**
* Approximately **57–60 questions**
* Multiple-choice and multiple-select
* Some questions explicitly tell you how many answers to select
* **No negative marking**
* Proctored
* Available through online proctoring or a physical test center

### Important

If a question says:

> Select TWO answers.

You need to select exactly two.

Don't accidentally select three because all three sound technically correct.

---

# 10. No Negative Marking

This is simple but important.

If you don't know an answer:

```text
Don't leave it blank.
```

Make your best choice.

Your goal is to answer every question.

---

# 11. Exam Booking

The basic booking process in the source is:

```text
HashiCorp certification account
          ↓
Select Terraform Associate (004)
          ↓
Choose:
   Online proctored
       OR
   Test center
          ↓
Choose date/time
          ↓
Pay
          ↓
Confirmation email
```

The source specifically recommends checking the **current official candidate handbook** for exam-day requirements because proctoring requirements can change. 

---

# 12. Online Exam Requirements

For an online-proctored exam, be prepared for requirements such as:

* Government-issued photo ID
* Private/clean testing area
* No unauthorized people
* No extra monitors
* Clear desk
* Stable internet
* Working webcam
* Working microphone

### Important

Don't rely blindly on old course notes for these requirements.

Before exam day, verify the current rules from HashiCorp/the proctoring provider.

---

# 13. Exam Time Management

You have approximately:

```text
60 minutes
÷
~57–60 questions
≈
about 1 minute/question
```

Don't spend five minutes fighting one difficult question.

A better approach:

```text
Easy question
    ↓
Answer quickly

Difficult question
    ↓
Think
    ↓
If taking too long → move on
    ↓
Return later
```

The goal is to make sure one difficult question doesn't prevent you from answering several easy questions at the end.

---

# 14. Read the Question Carefully

This is one of the most useful exam strategies.

Read the question carefully **before looking for an answer you recognize**.

Why?

Because Terraform questions often include answers that are:

> technically true, but don't answer the question.

Example:

> "Which command checks whether the Terraform configuration is syntactically valid without contacting the provider?"

Possible answers might include:

```text
terraform init
terraform validate
terraform plan
terraform apply
```

Several commands are important Terraform commands.

But the specific requirement points to:

```text
terraform validate
```

So always match:

```text
Question requirement
        ↓
Exact Terraform concept
```

---

# 15. Highest-Yield Topics to Review

These are the concepts in the source that are particularly easy to confuse.

## 1. `count` vs `for_each`

Especially **index instability**.

Remember:

```text
count
= numeric index
```

```text
for_each
= stable key
```

Example:

```text
count:

[0] alice
[1] bob
[2] carol
```

Remove Bob:

```text
[0] alice
[1] carol
```

Terraform sees the object at `[1]` as changed.

With `for_each`:

```text
alice → alice
bob   → removed
carol → carol
```

Stable keys make `for_each` safer for named resources.

---

# 16. Implicit vs Explicit Dependencies

### Implicit

Terraform sees the reference:

```hcl
instance = aws_instance.web.id
```

Therefore:

```text
aws_instance.web
       ↓
aws_eip.web
```

### Explicit

Terraform cannot infer the relationship, so you tell it:

```hcl
depends_on = [
  aws_iam_role_policy.s3_access
]
```

Mental model:

```text
Reference
   ↓
Implicit

depends_on
   ↓
Explicit
```

---

# 17. `sensitive = true` Does NOT Mean Encrypted State

This is a major trap.

```hcl
variable "password" {
  type      = string
  sensitive = true
}
```

This generally hides the value from normal CLI output.

But it does **not automatically mean**:

```text
Not stored in state
```

Remember:

```text
sensitive
   ↓
Hide from CLI output

NOT

Encrypt/remove from state
```

This distinction appears in multiple domains.

---

# 18. Variable Precedence

Memorize the order from the course:

```text id="1iyh3w"
1. -var / -var-file on CLI
              ↓
2. *.auto.tfvars
              ↓
3. terraform.tfvars
              ↓
4. TF_VAR_ environment variables
              ↓
5. default in variable block
```

Highest priority:

```text
-var / -var-file
```

Lowest:

```text
default
```

---

# 19. `terraform validate` vs `terraform plan`

Very important.

### `terraform validate`

Checks the Terraform configuration itself.

```text
Syntax
Configuration structure
Internal consistency
```

It doesn't perform the full real-world planning operation against your infrastructure.

---

### `terraform plan`

Calculates the proposed infrastructure changes.

```text
Configuration
     ↓
Current state
     ↓
Provider information
     ↓
Proposed changes
```

So:

```text
validate
= Is my Terraform configuration valid?

plan
= What changes will Terraform make?
```

---

# 20. Module State Ownership

A common misconception:

> "Every Terraform module has its own state file."

**Wrong.**

Normally:

```text
Root module
    │
    ├── Child module A
    └── Child module B
           │
           ▼
      Same state tree
```

Resources have addresses such as:

```text
module.vpc.aws_vpc.main
```

The module doesn't automatically create an independent state file.

---

# 21. Backend Blocks Cannot Use Variables

Another specific exam trap.

You might want:

```hcl
terraform {
  backend "s3" {
    bucket = var.bucket_name
  }
}
```

But backend configuration is processed before normal Terraform input variables are available.

Therefore backend configuration cannot simply use:

```text
var.*
```

Think:

```text
Backend initialization
        ↓
Very early
        ↓
Before normal variable evaluation
```

So backend configuration is handled separately.

---

# 22. HCP Terraform Workspace vs CLI Workspace

Again, memorize this.

```text
terraform workspace
        ↓
CLI concept
        ↓
Different state for configuration
```

Whereas:

```text
HCP Terraform workspace
        ↓
Managed HCP Terraform object
        ↓
State + variables + runs + permissions
```

Same word.

Different concept.

---

# 23. Sentinel vs Variable Validation

Another very important distinction.

### Variable validation

```hcl
variable "instance_type" {
  validation {
    ...
  }
}
```

This is part of the Terraform configuration.

### Sentinel

```text
HCP Terraform
      ↓
Sentinel policy
      ↓
Organization-wide governance
```

For example:

```text
"No public S3 buckets"
```

can be enforced centrally.

Mental model:

```text
Variable validation
= configuration-level input rule

Sentinel
= centralized governance policy
```

---

# 24. Provisioners

Provisioners should be one of the easiest questions if you remember the main rule:

> **Provisioners are a last resort.**

Preferred order:

```text
Provider-native feature
        ↓
Packer/image baking
        ↓
Configuration management
        ↓
Provisioner
```

And:

```text
local-exec
= local machine

remote-exec
= remote machine
```

---

# 25. Cross-Domain Practice Questions

Now the source gives you harder questions that combine several concepts.

These are worth attempting **without looking at the answers first**.

---

## Scenario A — State & Collaboration

### Question 1

Two engineers each have their own local Terraform state.

Both create what they believe should be the same application security group.

What are the two root problems?

Think about:

```text
State location
+
Team collaboration
```

And ask:

> What single architecture change would provide a shared source of truth?

---

### Question 2

A downstream project reads a value from another Terraform project's state.

It suddenly receives `null`.

The upstream team says:

> "We didn't remove anything."

How would you investigate?

A useful direction is to inspect the upstream state and verify whether the expected resource/output actually exists.

For example:

```bash
terraform state show <resource-address>
```

The important skill is distinguishing:

```text
"Application code didn't change"
```

from:

```text
"State/output/resource changed"
```

---

# 26. Scenario B — Configuration Language

### Question 3

You have:

```text
count-based resources
```

and remove an item from the middle of the list.

A separate resource references:

```hcl
aws_instance.web[*].id
```

Now that resource also shows an unexpected change.

Think through the chain:

```text
Remove item from list
       ↓
count indexes shift
       ↓
Different instance now occupies an index
       ↓
Splat produces a different collection of IDs
       ↓
Dependent resource sees changed input
       ↓
Plan shows additional changes
```

This is why understanding `count` index instability matters beyond the `count` resource itself.

---

# 27. Scenario B — Module Validation

Suppose:

```text
Root module
    ↓
has variable validation

Child module
    ↓
does NOT have that validation
```

The child module is then called directly by another root module with an invalid value.

Does the original root module's validation protect the child?

**No.**

Why?

Because variable validation belongs to the module where the variable is declared.

```text
Root A validation
      ↓
Only Root A's input
```

It isn't a global validation rule that automatically applies to every caller.

Therefore, if the child module itself needs to guarantee a constraint, that constraint should be enforced appropriately within the child module.

---

# 28. Scenario C — `prevent_destroy` + `moved`

Suppose a resource has:

```hcl
lifecycle {
  prevent_destroy = true
}
```

and you rename it using:

```hcl
moved {
  from = aws_instance.web
  to   = aws_instance.app_server
}
```

Think carefully about what each mechanism does.

### `prevent_destroy`

Means:

> Don't allow Terraform to destroy this resource.

### `moved`

Means:

> This is the same existing object, but its Terraform address has changed.

So the conceptual operation is:

```text
Old address
aws_instance.web
        ↓
moved
        ↓
New address
aws_instance.app_server
```

The `moved` block isn't intended to destroy the underlying infrastructure.

Therefore the rename itself isn't a normal destroy operation that `prevent_destroy` is designed to block.

---

# 29. Scenario C — Sentinel Bypass

Suppose:

```text
HCP Terraform workspace
      ↓
Sentinel policy
      ↓
"No public S3 buckets"
```

But an engineer runs:

```bash
terraform apply
```

from their laptop using local credentials and the same state.

Does Sentinel automatically intercept the local apply?

**No.**

The key point is:

```text
HCP Terraform remote run
        ↓
HCP governance/policies

Local Terraform run
        ↓
Not passing through HCP's run pipeline
```

So if the organization needs to prevent this bypass, access/workspace configuration must be designed so users cannot simply perform unauthorized local applies against the environment.

---

# 30. Scenario D — Troubleshooting

Suppose:

```text
terraform plan
```

randomly fails in CI:

```text
1 out of 8 runs
```

with a generic AWS error.

Don't immediately assume:

```text
Terraform code is wrong.
```

Use the troubleshooting process:

```text
Read exact error
      ↓
terraform validate
      ↓
Check Terraform/provider versions
      ↓
Check AWS/API/network conditions
      ↓
Reproduce if possible
      ↓
TF_LOG when normal information isn't enough
      ↓
Inspect detailed provider/API interaction
      ↓
Determine whether this is a provider bug
```

Use verbose logging when you need deeper information about what Terraform/provider is actually doing.

---

# 31. Scenario D — Provisioner Failure After Instance Replacement

Suppose:

```text
Initial EC2
   ↓
remote-exec
   ↓
Application installed
```

Everything works.

Six months later:

```text
AMI changed
   ↓
EC2 destroyed/recreated
   ↓
remote-exec runs again
   ↓
SSH connection fails
   ↓
Application isn't configured
```

The underlying weakness is the dependency on a **live SSH connection** during Terraform execution.

A stronger approach would be:

### `user_data`

for boot-time configuration, or:

### Packer

for creating an image that already contains the application.

For something that should always be present in a production image, Packer can be especially useful:

```text
Packer
  ↓
Preconfigured AMI
  ↓
Terraform
  ↓
New EC2
  ↓
Application already present
```

This removes the runtime provisioning dependency. 

---

# ⭐ Final Exam Revision Checklist

Before sitting the exam, make sure you can confidently explain these **without looking at your notes**:

### Terraform basics

* [ ] Declarative vs imperative
* [ ] Idempotency
* [ ] Terraform Core vs provider
* [ ] Provider version constraints
* [ ] `.terraform.lock.hcl`
* [ ] `terraform init`
* [ ] `validate`
* [ ] `plan`
* [ ] `apply`
* [ ] `destroy`

### Resources & expressions

* [ ] Resource vs data source
* [ ] Resource references
* [ ] Outputs
* [ ] Variables
* [ ] Variable precedence
* [ ] List vs set vs map vs object
* [ ] `count`
* [ ] `for_each`
* [ ] Index instability
* [ ] Conditional expressions
* [ ] Functions
* [ ] Locals
* [ ] Dynamic blocks
* [ ] Splat expressions
* [ ] `zipmap`

### Dependencies & lifecycle

* [ ] Implicit dependency
* [ ] `depends_on`
* [ ] `create_before_destroy`
* [ ] `prevent_destroy`
* [ ] `ignore_changes`
* [ ] Variable validation
* [ ] Preconditions
* [ ] Postconditions
* [ ] Check blocks
* [ ] `moved`

### Modules

* [ ] Root vs child module
* [ ] Module variables
* [ ] Module outputs
* [ ] Variable scope
* [ ] Module sources
* [ ] Module versions
* [ ] Module/provider relationship
* [ ] Module state addressing
* [ ] No separate state automatically per module

### State

* [ ] State purpose
* [ ] State locking
* [ ] Remote backends
* [ ] Backend configuration
* [ ] Backend cannot use normal variables
* [ ] State migration
* [ ] Drift
* [ ] `terraform state` commands
* [ ] Sensitive data in state

### HCP Terraform

* [ ] Organization
* [ ] Project
* [ ] Workspace
* [ ] CLI workspace vs HCP workspace
* [ ] CLI-driven workflow
* [ ] VCS-driven workflow
* [ ] Teams
* [ ] Permissions
* [ ] Sentinel
* [ ] Health assessments
* [ ] Private Registry
* [ ] Run Triggers
* [ ] HCP Terraform vs Terraform Enterprise

### Provisioners

* [ ] Provisioners = last resort
* [ ] `local-exec`
* [ ] `remote-exec`
* [ ] `file`
* [ ] `self`
* [ ] `connection`
* [ ] Creation-time vs destroy-time
* [ ] `on_failure`
* [ ] Tainted resource after failed provisioner
* [ ] `user_data` / Packer preferred where appropriate

---

# 🧠 The Final Mental Model

If you can remember this structure, most of the exam becomes much easier:

```text
Terraform Configuration
        │
        ├── Variables → INPUT
        │
        ├── Resources → CREATE/MANAGE
        │
        ├── Data → READ
        │
        ├── Modules → REUSE
        │
        ├── Functions/Locals → CALCULATE/REUSE
        │
        └── Outputs → EXPOSE
                │
                ▼
          Terraform Plan
                │
                ▼
             Provider
                │
                ▼
        Cloud/API infrastructure
                │
                ▼
              State
```

Then layer the advanced concepts on top:

```text
State
 ├── Backend
 ├── Locking
 └── Drift

Resources
 ├── count
 ├── for_each
 ├── lifecycle
 └── dependencies

Modules
 ├── variables
 ├── outputs
 └── providers

HCP Terraform
 ├── Workspaces
 ├── Teams
 ├── Sentinel
 ├── Registry
 └── Remote Runs
```

### 🔥 And the 10 distinctions I'd memorize right before the exam

```text
count              → numeric indexes
for_each            → stable keys

implicit dependency → Terraform sees reference
depends_on          → you explicitly tell Terraform

validate             → checks configuration
plan                 → calculates proposed changes

sensitive            → hides CLI output
state                → may still contain plaintext

CLI workspace        → state separation concept
HCP workspace        → managed HCP object

Sentinel             → centralized governance
variable validation  → configuration-level validation

HCP Terraform       → SaaS
Terraform Enterprise → self-hosted

Provisioner          → last resort
```

**At this point, the most valuable next step is not another passive read of all the domains — it's doing the practice questions/challenges without looking at the answers, then reviewing only the concepts you miss.**
