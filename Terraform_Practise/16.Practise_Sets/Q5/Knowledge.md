# Terraform List vs Map Conversion with for_each (Complete Guide)

This is one of the most important Terraform concepts. Let's use **subnets** in all three cases so you can clearly see the differences.

---

# Case 1: Variable is a LIST → Convert to MAP (Most Common)

This is exactly what you've been doing.

## variables.tf

```hcl
variable "subnets" {

  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}
```

---

## terraform.tfvars

```hcl
subnets = [
  {
    name = "public-1"
    cidr = "10.0.1.0/24"
    az   = "ap-south-1a"
  },
  {
    name = "private-1"
    cidr = "10.0.2.0/24"
    az   = "ap-south-1a"
  }
]
```

Notice this is a **list**.

```
[
  subnet1,
  subnet2
]
```

---

## main.tf

```hcl
resource "aws_subnet" "subnets" {

  for_each = {
    for s in var.subnets :
    s.name => s
  }

  cidr_block = each.value.cidr
  availability_zone = each.value.az
}
```

Terraform first converts

```
[
    subnet1,
    subnet2
]
```

into

```
{
   "public-1"  = subnet1
   "private-1" = subnet2
}
```

Now `for_each` can iterate.

Iteration 1

```
each.key

public-1

each.value

{
 name="public-1"
 cidr="10.0.1.0/24"
 az="ap-south-1a"
}
```

Iteration 2

```
each.key

private-1

each.value

{
 name="private-1"
 cidr="10.0.2.0/24"
 az="ap-south-1a"
}
```

This is the **most common production pattern** because users naturally provide a list.

---

# Case 2: Variable is a MAP → Convert to LIST (Vice Versa)

Suppose your input is already a map.

## variables.tf

```hcl
variable "subnets" {

  type = map(object({
    cidr = string
    az   = string
  }))
}
```

---

## terraform.tfvars

```hcl
subnets = {

  public-1 = {
    cidr = "10.0.1.0/24"
    az   = "ap-south-1a"
  }

  private-1 = {
    cidr = "10.0.2.0/24"
    az   = "ap-south-1a"
  }

}
```

Now suppose someone asks

> "Give me only the subnet CIDRs."

You convert the map to a list.

```hcl
output "cidrs" {

  value = [
    for subnet in var.subnets :
    subnet.cidr
  ]

}
```

Result

```
[
 "10.0.1.0/24",
 "10.0.2.0/24"
]
```

Or

```hcl
output "names" {

  value = [
    for name, subnet in var.subnets :
    name
  ]

}
```

Result

```
[
 "public-1",
 "private-1"
]
```

Here

Map

```
{
 public-1 = {...}
 private-1 = {...}
}
```

↓

List

```
[
 "public-1",
 "private-1"
]
```

---

# Case 3: Variable is already a MAP (No Conversion Needed)

This is even simpler.

## variables.tf

```hcl
variable "subnets" {

  type = map(object({
    cidr = string
    az   = string
  }))
}
```

---

## terraform.tfvars

```hcl
subnets = {

  public-1 = {
    cidr = "10.0.1.0/24"
    az   = "ap-south-1a"
  }

  private-1 = {
    cidr = "10.0.2.0/24"
    az   = "ap-south-1a"
  }

}
```

---

## main.tf

```hcl
resource "aws_subnet" "subnets" {

  for_each = var.subnets

  cidr_block = each.value.cidr

  availability_zone = each.value.az

  map_public_ip_on_launch = can(regex("public", each.key))
}
```

No conversion required.

Terraform already has

```
{
 public-1 = {...}

 private-1 = {...}
}
```

So

Iteration 1

```
each.key

public-1

each.value

{
 cidr="10.0.1.0/24"
 az="ap-south-1a"
}
```

Iteration 2

```
each.key

private-1

each.value

{
 cidr="10.0.2.0/24"
 az="ap-south-1a"
}
```

---

# Visual Summary

## Case 1

```
terraform.tfvars

[
 subnet1
 subnet2
]

        │
        ▼

for s in var.subnets

        │
        ▼

{
 public-1 = subnet1
 private-1 = subnet2
}

        │
        ▼

for_each
```

---

## Case 2

```
terraform.tfvars

{
 public-1 = {...}
 private-1 = {...}
}

        │
        ▼

[
 public-1
 private-1
]
```

---

## Case 3

```
terraform.tfvars

{
 public-1 = {...}
 private-1 = {...}
}

        │
        ▼

for_each = var.subnets

        │
        ▼

No conversion required
```

---

# Which one is used most in production?

| Input Type                | Usage                                                    | Why                                                                          |
| ------------------------- | -------------------------------------------------------- | ---------------------------------------------------------------------------- |
| **list(object)**          | ⭐⭐⭐⭐⭐ Very common                                        | Easier for users to provide ordered data; convert to a map for `for_each`.   |
| **map(object)**           | ⭐⭐⭐⭐ Common                                              | Great when names (keys) are naturally unique, like subnet names.             |
| **map → list conversion** | ⭐⭐⭐ Used in outputs, filtering, and data transformations | Useful when a consumer needs only selected values (IDs, CIDRs, names, etc.). |

For reusable modules, you'll most often see **Case 1** or **Case 3**. Case 2 is mainly used when you need to transform data for outputs or pass it to another resource in a different shape.

---
# Regex Working in the configuration files

**`regex()` is case-sensitive by default.**

So your expression:

```hcl
for_each = {
  for s in var.subnets :
  s.name => s
  if can(regex("public", s.name))
}
```

matches only if `"public"` appears exactly in lowercase.

### Matches ✅

```text
public-1
my-public-subnet
public
abc-public-xyz
```

### Does NOT match ❌

```text
Public-1
PUBLIC-1
PuBlIc-1
PRIVATE-1
```

---

## How `regex()` works

Terraform's `regex(pattern, string)` searches for the pattern **anywhere** in the string.

Example:

```hcl
regex("public", "public-1")
```

returns a match.

```hcl
regex("public", "my-public-subnet")
```

also returns a match.

But

```hcl
regex("public", "Public-1")
```

throws an error because it doesn't match.

That's why you wrapped it in `can()`:

```hcl
can(regex("public", s.name))
```

If there's no match, `regex()` would normally error. `can()` converts that into `false`.

---

## Making it case-insensitive

### Option 1 (Recommended)

Convert the string to lowercase:

```hcl
can(regex("public", lower(s.name)))
```

Now all of these match:

```text
public-1
Public-1
PUBLIC-1
PuBlIc-1
```

---

### Option 2

Use a regex flag:

```hcl
regex("(?i)public", s.name)
```

`(?i)` means case-insensitive.

---

## Which is better?

For Terraform modules, I recommend:

```hcl
can(regex("public", lower(s.name)))
```

or even simpler:

```hcl
contains(lower(s.name), "public")
```

Actually, the last one isn't valid because `contains()` is for lists, tuples, and sets—not strings.

### The cleanest options are:

```hcl
can(regex("public", lower(s.name)))
```

or

```hcl
strcontains(lower(s.name), "public")
```

If you're using a recent Terraform version (1.5+), `strcontains()` is even more readable because you're checking for a substring, not performing regular expression matching.

For your use case, where you're just distinguishing `"public"` and `"private"` subnets by name, `strcontains(lower(s.name), "public")` is the simplest and most expressive choice.
