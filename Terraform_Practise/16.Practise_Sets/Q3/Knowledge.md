# Terraform AWS Security Group - Current Industry Standard (Terraform 1.x + AWS Provider v6.x)

## Interview Question

### Requirement

Create a Security Group that:

* Allows SSH (Port 22)
* Allows HTTP (Port 80)
* Allows all outbound traffic

---

# Evolution of Security Group Management

Terraform has supported **three approaches** to manage AWS Security Groups over time.

```
1. Inline ingress/egress blocks      (Legacy)

                ↓

2. aws_security_group_rule           (Legacy for new code)

                ↓

3. aws_vpc_security_group_ingress_rule
   aws_vpc_security_group_egress_rule   ✅ Current Best Practice
```

As of **Terraform 1.x + AWS Provider v6.x**, HashiCorp recommends **Option 3** for new configurations.

---

# Option 1 - Current Industry Standard (Recommended) ✅

Create the Security Group separately and manage every rule as its own Terraform resource.

```hcl
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Web Security Group"
  vpc_id      = data.aws_vpc.selected.id

  tags = {
    Name = "web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "custom_ingress" {

  for_each = {
    for r in var.ingress_rules :
    "${r.from_port}-${r.to_port}-${r.protocol}-${r.cidr}" => r
  }

  security_group_id = aws_security_group.web_sg.id

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.protocol
  cidr_ipv4   = each.value.cidr
  description = each.value.description
}

resource "aws_vpc_security_group_egress_rule" "custom_egress" {

  for_each = {
    for r in var.egress_rules :
    "${r.protocol}-${r.cidr}" => r
  }

  security_group_id = aws_security_group.web_sg.id

  ip_protocol = each.value.protocol
  cidr_ipv4   = each.value.cidr
  description = each.value.description
}
```

---

# Why is this the Best Practice?

Every Security Group rule becomes its own Terraform resource.

Example Terraform State

```
aws_security_group.web_sg

aws_vpc_security_group_ingress_rule.custom_ingress["22-22-tcp-10.0.0.0/16"]

aws_vpc_security_group_ingress_rule.custom_ingress["80-80-tcp-0.0.0.0/0"]

aws_vpc_security_group_egress_rule.custom_egress["-1-0.0.0.0/0"]
```

Terraform knows exactly which rule changed.

Suppose you add HTTPS.

```
443
```

Terraform Plan

```
+ aws_vpc_security_group_ingress_rule.custom_ingress["443-443-tcp-0.0.0.0/0"]
```

Only one new rule is created.

Nothing else changes.

---

Suppose you remove HTTP.

Terraform destroys only

```
aws_vpc_security_group_ingress_rule.custom_ingress["80-80-tcp-0.0.0.0/0"]
```

SSH remains untouched.

Egress remains untouched.

This results in cleaner plans and more predictable lifecycle management.

---

# Option 2 - Legacy Resource

Earlier Terraform versions introduced `aws_security_group_rule`.

Example

```hcl
resource "aws_security_group_rule" "ssh" {

  type              = "ingress"
  security_group_id = aws_security_group.web_sg.id

  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}
```

This was better than inline rules because Security Group rules became separate resources.

However, **HashiCorp now recommends using `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule` for new configurations** because they map more closely to AWS Security Group Rule IDs and provide improved lifecycle behavior.

---

# Option 3 - Inline Rules (Older Style)

Earlier AWS Provider versions encouraged inline rules.

```hcl
resource "aws_security_group" "web_sg" {

  name   = "web-sg"
  vpc_id = data.aws_vpc.selected.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

This still works.

However, it is **not the preferred approach** for reusable modules or large production environments.

---

# Option 4 - Dynamic Blocks

Some projects still use:

```hcl
resource "aws_security_group" "web_sg" {

  dynamic "ingress" {

    for_each = var.ingress_rules

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = [ingress.value.cidr]
    }
  }

  dynamic "egress" {

    for_each = var.egress_rules

    content {
      protocol    = egress.value.protocol
      cidr_blocks = [egress.value.cidr]
    }
  }
}
```

This pattern was very common around:

* Terraform 0.12
* AWS Provider v3
* Early v4

Today it is generally considered a legacy approach for Security Groups because dedicated Security Group Rule resources now exist.

---

# Why Companies Prefer Separate Rule Resources

Suppose your Security Group contains

```
SSH
HTTP
HTTPS
```

If you remove

```
HTTP
```

Terraform using standalone resources produces

```
SSH     -> unchanged

HTTP    -> destroyed

HTTPS   -> unchanged
```

Only one resource changes.

This produces:

* Smaller Terraform plans
* Easier reviews
* Better lifecycle management
* Reduced drift
* Safer production deployments

---

# Current AWS Provider Recommendation

For **Terraform 1.x + AWS Provider v6.x**, HashiCorp recommends:

✅ Create the Security Group using

```
aws_security_group
```

✅ Create ingress rules using

```
aws_vpc_security_group_ingress_rule
```

✅ Create egress rules using

```
aws_vpc_security_group_egress_rule
```

✅ Use `for_each` when rules are data-driven.

❌ Avoid using `aws_security_group_rule` for new configurations.

❌ Avoid inline `ingress` and `egress` blocks for reusable modules.

❌ Do not mix multiple Security Group rule resource types for the same Security Group.

For example, don't combine:

```
aws_security_group
      ingress { }

aws_security_group_rule

aws_vpc_security_group_ingress_rule
```

Managing the same Security Group with multiple rule resource types can result in conflicts, perpetual diffs, or unexpected behavior.

---

# What Big Companies Usually Use

Most organizations don't hardcode individual Security Group rules.

Instead they create reusable Terraform modules.

```
            terraform.tfvars

                    │

                    ▼

            ingress_rules
            egress_rules

                    │

                    ▼

            Reusable Security Group Module

                    │

                    ▼
          aws_security_group
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
aws_vpc_security_group_      aws_vpc_security_group_
ingress_rule                 egress_rule
```

The module never changes.

Only the input variables change.

Example:

Application A

```
SSH
HTTP
HTTPS
```

Application B

```
SSH
MySQL
Redis
Kafka
```

Application C

```
HTTPS
Prometheus
Grafana
```

All applications use the same Terraform module.

Only the input variables differ.

This makes the module reusable, scalable, and easy to maintain.

---

If you want to define `ingress_rules` as a **map** instead of a **list**, each rule needs a **unique key** (for example `ssh`, `http`, `https`).

## variables.tf

```hcl
variable "ingress_rules" {
  description = "Ingress security group rules"

  type = map(object({
    from_port  = number
    to_port    = number
    protocol   = string
    cidr       = string
    description = string
  }))
}
```

---

## terraform.tfvars

```hcl
ingress_rules = {
  ssh = {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    cidr       = "10.0.0.0/16"
    description = "SSH access"
  }

  http = {
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    cidr       = "0.0.0.0/0"
    description = "HTTP access"
  }
}
```

Now the keys are:

* `ssh`
* `http`

and the values are the rule objects.

---

## Resource

Now your resource becomes much simpler because `for_each` can directly iterate over a map.

```hcl
resource "aws_vpc_security_group_ingress_rule" "custom_ingress" {
  for_each = var.ingress_rules

  security_group_id = aws_security_group.web_sg.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr
  description       = each.value.description
}
```

Notice we **don't need**

```hcl
for_each = {
  for r in var.ingress_rules :
  "${r.from_port}-${r.to_port}-${r.cidr}" => r
}
```

because it's already a map.

---

## Why do many Terraform modules still use a `list(object)`?

Most users naturally think of security rules as a list:

```hcl
ingress_rules = [
  {...},
  {...},
  {...}
]
```

rather than inventing keys like:

```hcl
ingress_rules = {
  rule1 = {...}
  rule2 = {...}
  rule3 = {...}
}
```

So modules often accept a **list** for user convenience and then internally convert it to a map for `for_each`:

```hcl
for_each = {
  for r in var.ingress_rules :
  "${r.from_port}-${r.to_port}-${r.cidr}" => r
}
```

This gives users a simple input format while still satisfying Terraform's requirement that `for_each` operate on a map or set with stable keys.

### Which approach is better?

* **Use `list(object)`** when the input is naturally an ordered collection and you want the module to be easy for consumers to use. Convert it to a map internally if needed. This is very common in reusable modules.
* **Use `map(object)`** when each item already has a meaningful, unique name (like `ssh`, `http`, `db`) or when you want callers to explicitly control the resource instance keys. This also lets you use `for_each = var.ingress_rules` directly.


# Why Use `for_each`?

Instead of writing

```hcl
resource "aws_vpc_security_group_ingress_rule" "ssh" {}

resource "aws_vpc_security_group_ingress_rule" "http" {}

resource "aws_vpc_security_group_ingress_rule" "https" {}
```

Production modules define rules as data:

```hcl
variable "ingress_rules" {
  type = map(object({
    from_port  = number
    to_port    = number
    protocol   = string
    cidr       = string
    description = string
  }))
}
```

Then create all rules with one resource:

```hcl
resource "aws_vpc_security_group_ingress_rule" "this" {

  for_each = var.ingress_rules

  security_group_id = aws_security_group.web_sg.id

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.protocol
  cidr_ipv4   = each.value.cidr
  description = each.value.description
}
```

Benefits:

* One reusable module
* No duplicated code
* Easy to add/remove rules
* Stable Terraform resource addresses
* Cleaner Terraform plans

---

# When is `dynamic` Still Useful?

`dynamic` remains the correct solution when a Terraform resource supports repeated nested blocks **and there is no standalone resource**.

Examples include:

* Multiple `ebs_block_device` blocks in an EC2 instance
* Multiple `setting` blocks in an Elastic Beanstalk environment
* Multiple `default_action` blocks in an ALB Listener
* Any resource exposing repeatable nested blocks without separate Terraform resources

For these resources, `dynamic` is still the recommended pattern.

---

# Interview Answer (Production Best Practice)

If asked in an interview:

> **"How would you create a Security Group in Terraform?"**

A strong answer would be:

* Use `aws_security_group` to create the Security Group.
* Use `aws_vpc_security_group_ingress_rule` for each ingress rule.
* Use `aws_vpc_security_group_egress_rule` for each egress rule.
* Define Security Group rules as input variables (`map(object(...))` or `list(object(...))`).
* Use `for_each` to create one Terraform resource per Security Group rule.
* Avoid inline `ingress`/`egress` blocks for new reusable modules.
* Avoid `aws_security_group_rule` for new configurations.
* Do not mix different Security Group rule resource types for the same Security Group.

---

# Final Recommendation

For **Terraform 1.x with AWS Provider v6.x**, the current production-grade approach is:

```
                 Security Group
                       │
                       ▼
          aws_security_group
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
aws_vpc_security_group_      aws_vpc_security_group_
ingress_rule                 egress_rule

```

This approach is:

* ✅ Officially recommended by HashiCorp for new configurations
* ✅ Widely adopted in enterprise Terraform modules
* ✅ Easier to maintain
* ✅ Produces cleaner execution plans
* ✅ Scales well across multiple applications and environments
* ✅ Aligns closely with AWS's underlying Security Group Rule model
