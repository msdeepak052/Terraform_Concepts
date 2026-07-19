# Question: Create a Simple Security Group
## Requirement: Allow SSH (port 22) and HTTP (port 80) from any IP.

Yes. **What you've written is actually closer to the current Terraform and AWS provider best practice** than using `dynamic` blocks.

Here's why.

---

# Option 1 (Recommended Industry Standard) ✅

This is exactly what you're using.

```hcl
resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = data.aws_vpc.selected.id
}

resource "aws_vpc_security_group_ingress_rule" "custom_ingress" {
  for_each = {
    for r in var.ingress_rules :
    "${r.from_port}-${r.to_port}-${r.cidr}" => r
  }

  security_group_id = aws_security_group.web_sg.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr
}
```

### Advantages

✅ Every rule becomes its own Terraform resource.

Example:

```
aws_vpc_security_group_ingress_rule.custom_ingress["22-22-10.0.0.0/16"]

aws_vpc_security_group_ingress_rule.custom_ingress["80-80-0.0.0.0/0"]
```

Terraform knows exactly which rule changed.

If you add

```
443
```

Terraform simply creates

```
+ aws_vpc_security_group_ingress_rule.custom_ingress["443-443-0.0.0.0/0"]
```

Nothing else changes.

---

If you delete HTTP

Terraform destroys only

```
80 rule
```

SSH remains untouched.

This is excellent for production.

---

# Option 2 (Older Way)

Earlier AWS provider versions encouraged this:

```hcl
resource "aws_security_group" "web_sg" {

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    ...
  }
}
```

No `for_each`.

No dynamic blocks.

This still works but is no longer the preferred approach for complex or reusable configurations.

---

# Option 3 (Dynamic Block)

Some people still do

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

This was very common around Terraform 0.12–1.2 and older AWS provider releases.

---

## Why many companies avoid this now

Suppose you have

```
22
80
443
```

If you remove

```
80
```

Terraform often has to re-evaluate the nested blocks inside the single `aws_security_group` resource. Depending on the provider behavior, plans can become noisier, and in older provider versions this sometimes resulted in unnecessary updates or replacement of multiple nested rules.

With separate rule resources:

```
22 -> unchanged

80 -> destroyed

443 -> unchanged
```

Much cleaner.

---

# AWS Provider Recommendation

The AWS provider introduced

```
aws_vpc_security_group_ingress_rule
```

and

```
aws_vpc_security_group_egress_rule
```

specifically to manage rules as independent resources.

This improves:

* Better lifecycle handling
* Fewer unintended changes
* Clearer plans
* Easier imports
* Reduced conflicts when multiple modules or teams manage different rules

---

# What do big companies usually use?

For reusable Terraform modules in organizations using AWS provider v4/v5/v6, a common pattern is:

```
Security Group
        │
        │
        ▼
aws_security_group

        │
        ├──────────────┐
        │              │
        ▼              ▼

aws_vpc_security_group_ingress_rule
        for_each

aws_vpc_security_group_egress_rule
        for_each
```

This is common in teams using EKS, ECS, platform engineering, and enterprise AWS environments.

---

# When is `dynamic` still useful?

`dynamic` is still appropriate when the provider resource only supports repeated nested blocks and there is no separate resource type. Examples include:

* Multiple `ebs_block_device` blocks in an EC2 instance
* Multiple `setting` blocks in an Elastic Beanstalk environment
* Repeated nested configuration blocks in resources that don't expose standalone resources

In those cases, `dynamic` is the right tool.

---

## Recommendation for interviews and production

For AWS security groups:

* ✅ Create the security group with `aws_security_group`.
* ✅ Manage ingress and egress rules using `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule`.
* ✅ Use `for_each` to create one resource per rule.
* ❌ Prefer not to use `dynamic` blocks for security group rules unless you're maintaining legacy code or have a specific reason.

For modern Terraform (1.x) with recent AWS provider versions, your approach is considered the more robust and maintainable pattern.
