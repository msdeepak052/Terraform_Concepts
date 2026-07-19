# **Terraform: Selecting a Public Subnet Dynamically**

When using a single `aws_subnet` resource with `for_each`, Terraform creates a **map** of subnet resources.

---

## Subnet Resource

```hcl
resource "aws_subnet" "subnets" {

  for_each = {
    for s in var.subnets : s.name => s
  }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  map_public_ip_on_launch = can(regex("public", each.key))
}
```

Suppose your input is:

```hcl
subnets = [
  {
    name = "public-subnet-1"
    cidr = "10.0.1.0/24"
    az   = "ap-south-1a"
  },
  {
    name = "public-subnet-2"
    cidr = "10.0.2.0/24"
    az   = "ap-south-1b"
  },
  {
    name = "private-subnet-1"
    cidr = "10.0.11.0/24"
    az   = "ap-south-1a"
  }
]
```

Terraform creates the following resource map:

```text
aws_subnet.subnets = {

  "public-subnet-1" = subnet-111

  "public-subnet-2" = subnet-222

  "private-subnet-1" = subnet-333

}
```

---

# Hardcoded Approach (Not Recommended)

```hcl
subnet_id = aws_subnet.subnets["public-subnet-1"].id
```

This always selects:

```text
subnet-111
```

### Why is this not recommended?

* Hardcoded subnet name
* Doesn't work if subnet names change
* Not reusable
* Doesn't support different environments

---

# Option 1 (Recommended): Filter Public Subnets and Select the First One

```hcl
subnet_id = [
  for name, subnet in aws_subnet.subnets :
  subnet.id
  if can(regex("public", name))
][0]
```

---

## Step-by-Step Execution

Terraform starts with:

```text
aws_subnet.subnets

{

  public-subnet-1 = subnet-111

  public-subnet-2 = subnet-222

  private-subnet-1 = subnet-333

}
```

### Step 1

Iterate through the map

```text
Iteration 1

name = public-subnet-1

subnet.id = subnet-111


Iteration 2

name = public-subnet-2

subnet.id = subnet-222


Iteration 3

name = private-subnet-1

subnet.id = subnet-333
```

---

### Step 2

Apply the filter

```hcl
if can(regex("public", name))
```

Result

```text
public-subnet-1 ✔

public-subnet-2 ✔

private-subnet-1 ✘
```

---

### Step 3

Terraform builds a new list

```text
[
  subnet-111,
  subnet-222
]
```

---

### Step 4

Take the first element

```hcl
[0]
```

Result

```text
subnet-111
```

---

## Visual Flow

```text
Resource Map

{
 public-subnet-1 = subnet-111
 public-subnet-2 = subnet-222
 private-subnet-1 = subnet-333
}

          │
          ▼

Filter only Public

[
 subnet-111
 subnet-222
]

          │
          ▼

[0]

          │
          ▼

subnet-111
```

---

# Option 2: Using `element()`

Terraform provides the `element()` function.

```hcl
subnet_id = element(
  [
    for name, subnet in aws_subnet.subnets :
    subnet.id
    if can(regex("public", name))
  ],
  0
)
```

This is equivalent to:

```hcl
subnet_id = [
  for name, subnet in aws_subnet.subnets :
  subnet.id
  if can(regex("public", name))
][0]
```

Both return:

```text
subnet-111
```

### Which is better?

Using:

```hcl
list[0]
```

is simpler and more common in modern Terraform.

`element()` was more common in older Terraform versions and has one special behavior: if the index is larger than the list length, it wraps around instead of failing.

Example:

```hcl
element(["A", "B", "C"], 4)
```

returns:

```text
B
```

because `4 % 3 = 1`.

In contrast:

```hcl
["A", "B", "C"][4]
```

produces an index out-of-range error.

---

# Option 3: Randomly Select a Public Subnet

Sometimes you want to choose a random public subnet.

First collect the public subnet IDs:

```hcl
locals {

  public_subnet_ids = [
    for name, subnet in aws_subnet.subnets :
    subnet.id
    if can(regex("public", name))
  ]

}
```

Create a random shuffle:

```hcl
resource "random_shuffle" "public_subnet" {

  input = local.public_subnet_ids

  result_count = 1
}
```

Use the randomly selected subnet:

```hcl
subnet_id = random_shuffle.public_subnet.result[0]
```

Example:

Suppose

```text
[
 subnet-111
 subnet-222
 subnet-333
]
```

One run may return

```text
[
 subnet-222
]
```

Another run may return

```text
[
 subnet-111
]
```

This is useful for demonstrations or certain testing scenarios, but it's **not a common choice for production infrastructure**, where deterministic placement is usually preferred.

---

# Which Option Should You Use?

| Option                                     | Use Case                                                           | Recommended                                |
| ------------------------------------------ | ------------------------------------------------------------------ | ------------------------------------------ |
| `aws_subnet.subnets["public-subnet-1"].id` | Fixed, known subnet                                                | ❌ Hardcoded                                |
| Filter + `[0]`                             | First public subnet dynamically                                    | ⭐⭐⭐⭐⭐ **Best Practice**                    |
| `element(filtered_list, 0)`                | Same as above, older style or when wrap-around behavior is desired | ⭐⭐⭐                                        |
| `random_shuffle`                           | Random subnet selection                                            | ⭐⭐ Mostly for testing or special scenarios |

## Production Recommendation

For reusable Terraform modules, the most common and maintainable pattern is:

```hcl
subnet_id = [
  for name, subnet in aws_subnet.subnets :
  subnet.id
  if can(regex("public", name))
][0]
```

It avoids hardcoded subnet names, automatically adapts if the public subnet names change, and works regardless of how many public subnets are defined.


---
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

---

This is one of the most important Terraform concepts. The key difference is **where the subnet information comes from**.

* `module.vpc.public_subnet_ids[0]` → **Gets a value from a module output** (a list).
* `aws_subnet.subnets[each.key].id` → **Gets a value directly from a resource map** using its key.

Let's look at a simple example.

---

# Example 1: Using `module.vpc.public_subnet_ids[0]`

Suppose your VPC module creates these subnets:

```text
public-subnet-1  → subnet-111
public-subnet-2  → subnet-222
private-subnet-1 → subnet-333
private-subnet-2 → subnet-444
```

The module has this output:

```hcl
output "public_subnet_ids" {
  value = [
    for name, subnet in aws_subnet.subnets :
    subnet.id
    if can(regex("public", name))
  ]
}
```

The output becomes:

```text
module.vpc.public_subnet_ids

[
  "subnet-111",
  "subnet-222"
]
```

Now if you write:

```hcl
subnet_id = module.vpc.public_subnet_ids[0]
```

Terraform picks:

```text
subnet_id = "subnet-111"
```

### Visual

```text
VPC Module

Creates

public-subnet-1 → subnet-111
public-subnet-2 → subnet-222

        │
        ▼

Output

[
 subnet-111,
 subnet-222
]

        │
        ▼

[0]

        │
        ▼

subnet-111
```

This is **outside the VPC module**. You're consuming an output that the module exposes.

---

# Example 2: Using `aws_subnet.subnets[each.key].id`

Suppose you already have this resource:

```hcl
resource "aws_subnet" "subnets" {
  for_each = {
    for s in var.subnets :
    s.name => s
  }
}
```

Terraform creates:

```text
aws_subnet.subnets = {

  "public-subnet-1" = subnet-111

  "public-subnet-2" = subnet-222

  "private-subnet-1" = subnet-333
}
```

Now imagine you're creating route table associations.

```hcl
resource "aws_route_table_association" "public" {

  for_each = {
    for s in var.subnets :
    s.name => s
    if can(regex("public", s.name))
  }

  subnet_id = aws_subnet.subnets[each.key].id
}
```

### First iteration

```text
each.key

public-subnet-1
```

Terraform evaluates:

```hcl
aws_subnet.subnets["public-subnet-1"].id
```

Result:

```text
subnet-111
```

### Second iteration

```text
each.key

public-subnet-2
```

Terraform evaluates:

```hcl
aws_subnet.subnets["public-subnet-2"].id
```

Result:

```text
subnet-222
```

### Visual

```text
each.key

public-subnet-1
       │
       ▼

aws_subnet.subnets["public-subnet-1"]

       │
       ▼

subnet-111
```

Here you're **inside the same module**, directly referencing the resource instances created by `for_each`.

---

# Why does `each.key` work?

Because both resources use the **same keys**.

Subnets:

```text
aws_subnet.subnets

{
  public-subnet-1
  public-subnet-2
}
```

Route table associations:

```text
for_each

{
  public-subnet-1
  public-subnet-2
}
```

So during iteration:

| each.key        | Looks up                                |
| --------------- | --------------------------------------- |
| public-subnet-1 | `aws_subnet.subnets["public-subnet-1"]` |
| public-subnet-2 | `aws_subnet.subnets["public-subnet-2"]` |

---

# Easy way to remember

## `module.vpc.public_subnet_ids[0]`

Think of it like asking a friend:

> "Give me your list of public subnet IDs."

The VPC module replies:

```text
[
 subnet-111
 subnet-222
]
```

You simply take the first one:

```text
[0]
```

---

## `aws_subnet.subnets[each.key].id`

Think of it like looking something up in a dictionary.

Dictionary:

```text
public-subnet-1 → subnet-111

public-subnet-2 → subnet-222
```

If someone tells you the key is:

```text
public-subnet-2
```

You look it up:

```text
Dictionary["public-subnet-2"]

↓

subnet-222
```

---

# Production usage

| Expression                        | Used Where?                                     | Purpose                                                                               |
| --------------------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------- |
| `aws_subnet.subnets[each.key].id` | **Inside the same module**                      | Reference a specific subnet resource created with `for_each`.                         |
| `module.vpc.public_subnet_ids[0]` | **Outside the module (root or another module)** | Consume the VPC module's output without needing to know how the subnets were created. |

### One-line rule

* **Inside a module:** use `aws_subnet.subnets[each.key].id` because you have direct access to the resources.
* **Outside a module:** use `module.vpc.public_subnet_ids[0]` because other modules can only access what the VPC module exposes through outputs.
