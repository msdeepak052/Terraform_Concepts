In production, engineers **do not hardcode an Availability Zone (AZ)** unless there is a specific requirement (for example, an EBS volume that already exists in a particular AZ).

There are three common approaches used in industry.

---

# Option 1 (Most Common) – Let AWS choose the AZ ✅

Don't specify either `availability_zone` or `subnet_id`.

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"
}
```

AWS automatically places the instance in one of the default VPC subnets.

**Good for:**

* Learning
* Quick testing
* Temporary environments

**Not recommended for production**, because you have very little control over networking.

---

# Option 2 (Industry Standard) – Deploy into a selected subnet

In production, every subnet belongs to exactly one AZ.

Example:

```
VPC
│
├── Public Subnet A (ap-south-1a)
├── Public Subnet B (ap-south-1b)
├── Public Subnet C (ap-south-1c)
│
├── Private Subnet A (ap-south-1a)
├── Private Subnet B (ap-south-1b)
└── Private Subnet C (ap-south-1c)
```

Terraform:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  subnet_id = var.private_subnet_id
}
```

Terraform doesn't need the AZ.

AWS automatically knows:

```
subnet-abc123
        │
        ▼
ap-south-1b
```

This is **how 95% of production deployments are done**.

---

# Option 3 (Highly Recommended) – Discover subnets dynamically

Instead of hardcoding subnet IDs, fetch them.

```hcl
data "aws_subnets" "private" {
  filter {
    name   = "tag:Type"
    values = ["Private"]
  }
}
```

Then:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  subnet_id = data.aws_subnets.private.ids[0]
}
```

This is common in reusable Terraform modules.

---

# What if I want any Availability Zone?

Use the AWS Availability Zones data source.

```hcl
data "aws_availability_zones" "available" {
  state = "available"
}
```

Outputs:

```
[
  "ap-south-1a",
  "ap-south-1b",
  "ap-south-1c"
]
```

Pick one:

```hcl
resource "aws_instance" "web" {
  ami               = var.ami_id
  instance_type     = "t3.micro"
  availability_zone = data.aws_availability_zones.available.names[0]
}
```

Or choose randomly:

```hcl
resource "random_shuffle" "az" {
  input        = data.aws_availability_zones.available.names
  result_count = 1
}

resource "aws_instance" "web" {
  ami               = var.ami_id
  instance_type     = "t3.micro"
  availability_zone = random_shuffle.az.result[0]
}
```

This is useful for labs, but **less common than using subnets**.

---

# What large companies do (Banks, Amazon, Microsoft, etc.)

For production workloads, they typically:

1. Create a VPC.
2. Create private and public subnets across multiple AZs.
3. Deploy EC2 instances into **subnets**, not by specifying `availability_zone`.
4. Use **Auto Scaling Groups (ASGs)** with **multiple subnet IDs**.

Example:

```hcl
vpc_zone_identifier = [
  subnet-a,
  subnet-b,
  subnet-c
]
```

AWS automatically launches instances in healthy AZs and balances capacity across them. If one AZ becomes unavailable, the ASG continues launching instances in the remaining AZs (subject to your configuration and capacity).

---

## Interview answer (6+ YOE)

If asked, *"How do you ensure EC2 launches in any available AZ?"*, a strong answer is:

> "In production, we don't typically specify the Availability Zone directly. We deploy instances into subnets, and each subnet is mapped to an AZ. For high availability, we use an Auto Scaling Group configured with subnets across multiple Availability Zones. AWS then automatically places instances across those AZs, providing resilience and balancing capacity. For standalone EC2 instances, we usually supply the appropriate subnet ID rather than an AZ."


---

This is one of the most important Terraform concepts. Let's go through it **exactly as Terraform processes it internally**, step by step.

---

# Step 1: Variable Input

Suppose your `terraform.tfvars` contains

```hcl
subnets = [
  {
    name = "subnet-public-1"
    cidr = "10.0.1.0/24"
    az   = "ap-south-1a"
  },
  {
    name = "subnet-public-2"
    cidr = "10.0.2.0/24"
    az   = "ap-south-1b"
  }
]
```

Terraform stores this as a **list of objects**.

Think of it like

```
var.subnets
│
├── Index 0
│      name = subnet-public-1
│      cidr = 10.0.1.0/24
│      az   = ap-south-1a
│
└── Index 1
       name = subnet-public-2
       cidr = 10.0.2.0/24
       az   = ap-south-1b
```

Notice this is a **LIST**.

Lists use indexes:

```
0
1
2
3
...
```

---

# Step 2: Why can't for_each directly use this?

`for_each` works with

* Map
* Set of strings

It **cannot uniquely track a list of objects**.

Terraform wants something like

```
Key ---> Value
```

Example

```
subnet-public-1 ---> Object
subnet-public-2 ---> Object
```

instead of

```
0 ---> Object
1 ---> Object
```

Why?

Because indexes change.

Example:

Initially

```
0 subnet-public-1
1 subnet-public-2
```

Now you insert one subnet at top

```
0 subnet-public-0
1 subnet-public-1
2 subnet-public-2
```

Everything shifted.

Terraform thinks every resource changed.

Bad.

---

# Step 3: The for expression

Now look at

```hcl
{
  for s in var.subnets :
  s.name => s
}
```

Let's execute it manually.

Terraform starts reading

```
var.subnets
```

which contains

```
Object 1

name=subnet-public-1
cidr=10.0.1.0/24
az=ap-south-1a

Object 2

name=subnet-public-2
cidr=10.0.2.0/24
az=ap-south-1b
```

---

## First Iteration

Terraform picks

```
s =
{
 name="subnet-public-1"
 cidr="10.0.1.0/24"
 az="ap-south-1a"
}
```

Now it evaluates

```
s.name => s
```

Left side becomes

```
subnet-public-1
```

Right side becomes

```
Entire object
```

Result so far

```
{
  subnet-public-1 =
  {
      name="subnet-public-1"
      cidr="10.0.1.0/24"
      az="ap-south-1a"
  }
}
```

---

## Second Iteration

Now

```
s =
{
 name="subnet-public-2"
 cidr="10.0.2.0/24"
 az="ap-south-1b"
}
```

Again

```
s.name => s
```

becomes

```
subnet-public-2 =>
{
 name="subnet-public-2"
 cidr="10.0.2.0/24"
 az="ap-south-1b"
}
```

Terraform adds it.

Final result

```hcl
{
  "subnet-public-1" = {
    name = "subnet-public-1"
    cidr = "10.0.1.0/24"
    az   = "ap-south-1a"
  }

  "subnet-public-2" = {
    name = "subnet-public-2"
    cidr = "10.0.2.0/24"
    az   = "ap-south-1b"
  }
}
```

Notice...

The list became a **map**.

---

# Visual Conversion

### Before

```
LIST

[
   Object1,
   Object2
]
```

↓

Terraform loops

```
Object1
Object2
```

↓

Creates keys

```
Object1.name
Object2.name
```

↓

Final

```
MAP

{
 subnet-public-1 = Object1
 subnet-public-2 = Object2
}
```

---

# Step 4: Now for_each receives this

```hcl
for_each = {
  subnet-public-1 = {...}
  subnet-public-2 = {...}
}
```

Terraform says

"I need two resources."

Resource 1

```
Key

subnet-public-1

Value

{
 name="subnet-public-1"
 cidr="10.0.1.0/24"
 az="ap-south-1a"
}
```

Resource 2

```
Key

subnet-public-2

Value

{
 name="subnet-public-2"
 cidr="10.0.2.0/24"
 az="ap-south-1b"
}
```

---

# Step 5: What is each.key?

During first iteration

```
each.key

subnet-public-1
```

During second

```
each.key

subnet-public-2
```

---

# Step 6: What is each.value?

First resource

```
each.value =
{
 name="subnet-public-1"
 cidr="10.0.1.0/24"
 az="ap-south-1a"
}
```

Second

```
each.value =
{
 name="subnet-public-2"
 cidr="10.0.2.0/24"
 az="ap-south-1b"
}
```

---

# Step 7: Now Terraform reads

```hcl
cidr_block = each.value.cidr
```

For first subnet

```
each.value.cidr

↓

10.0.1.0/24
```

Terraform writes

```hcl
cidr_block = "10.0.1.0/24"
```

---

Second subnet

```
each.value.cidr

↓

10.0.2.0/24
```

Terraform writes

```hcl
cidr_block = "10.0.2.0/24"
```

---

# Step 8: availability_zone

Terraform reads

```hcl
availability_zone = each.value.az
```

First resource

```
each.value.az

↓

ap-south-1a
```

Second resource

```
each.value.az

↓

ap-south-1b
```

---

# Step 9: Final resources Terraform creates

Terraform behaves **as if you had written**:

```hcl
resource "aws_subnet" "public1" {

  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}
```

and

```hcl
resource "aws_subnet" "public2" {

  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
}
```

But you only wrote one resource block.

---

# Step 10: Resource Addresses

Terraform stores them as

```
aws_subnet.public["subnet-public-1"]

aws_subnet.public["subnet-public-2"]
```

Notice it uses the **name** as the identity, not the list index.

---

# Why is this the industry standard?

Suppose you later add another subnet:

```hcl
subnets = [

  {
    name="subnet-public-0"
    cidr="10.0.0.0/24"
    az="ap-south-1a"
  },

  {
    name="subnet-public-1"
    cidr="10.0.1.0/24"
    az="ap-south-1a"
  },

  {
    name="subnet-public-2"
    cidr="10.0.2.0/24"
    az="ap-south-1b"
  }

]
```

With **count**, the indexes change:

```
0 → subnet-public-0
1 → subnet-public-1
2 → subnet-public-2
```

Terraform may plan to destroy and recreate resources because their indexes shifted.

With **for_each**, the keys remain:

```
subnet-public-1
subnet-public-2
```

Terraform simply creates the new key:

```
subnet-public-0
```

The existing resources keep the same identities, so they are left untouched. This stable identity is why using a map with `for_each` is the preferred pattern for managing collections of infrastructure in production.

### Mental model to remember

```
Input (List)

[
  {name="subnet-public-1", cidr="10.0.1.0/24", az="ap-south-1a"},
  {name="subnet-public-2", cidr="10.0.2.0/24", az="ap-south-1b"}
]

            │
            │  for s in var.subnets : s.name => s
            ▼

Map

{
  "subnet-public-1" = {name, cidr, az}
  "subnet-public-2" = {name, cidr, az}
}

            │
            ▼

for_each

each.key   = "subnet-public-1"
each.value = {name, cidr, az}

            │
            ▼

each.value.cidr → "10.0.1.0/24"
each.value.az   → "ap-south-1a"

            │
            ▼

Creates:

aws_subnet.public["subnet-public-1"]
```

This "list → map → for_each → each.key/each.value → resource" flow is the pattern you'll encounter in most production Terraform codebases because it gives Terraform stable, meaningful resource identities.


---

Excellent question. **If your input is already a map, then you don't need the conversion at all.** That's actually one of the reasons some teams prefer defining variables as maps from the start.

Let's compare both approaches.

---

# Approach 1 (Your Current Code)

### Variable

```hcl
variable "subnets" {
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}
```

### tfvars

```hcl
subnets = [
  {
    name = "subnet-public-1"
    cidr = "10.0.1.0/24"
    az   = "ap-south-1a"
  },
  {
    name = "subnet-public-2"
    cidr = "10.0.2.0/24"
    az   = "ap-south-1b"
  }
]
```

Since this is a **list**, Terraform cannot use it directly with `for_each`.

So you convert it.

```hcl
for_each = {
  for s in var.subnets :
  s.name => s
}
```

After conversion

```hcl
{
  subnet-public-1 = {
    name = "subnet-public-1"
    cidr = "10.0.1.0/24"
    az   = "ap-south-1a"
  }

  subnet-public-2 = {
    name = "subnet-public-2"
    cidr = "10.0.2.0/24"
    az   = "ap-south-1b"
  }
}
```

---

# Approach 2 (Input is already a map)

Now suppose your variable is defined differently.

```hcl
variable "subnets" {

  type = map(object({
    cidr = string
    az   = string
  }))
}
```

Notice something.

There is **no `name` field** inside the object.

Why?

Because the **map key itself becomes the name**.

---

## tfvars

Now your tfvars looks like this.

```hcl
subnets = {

  subnet-public-1 = {
    cidr = "10.0.1.0/24"
    az   = "ap-south-1a"
  }

  subnet-public-2 = {
    cidr = "10.0.2.0/24"
    az   = "ap-south-1b"
  }

}
```

This is already a map.

Terraform sees

```text
Key -------------------- Value

subnet-public-1 -------> Object
subnet-public-2 -------> Object
```

No conversion needed.

---

# Resource

Now your resource becomes simply

```hcl
resource "aws_subnet" "public" {

  for_each = var.subnets

  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = each.key
  }
}
```

Notice

```hcl
for_each = var.subnets
```

That's it.

No `for` expression.

---

# How Terraform iterates

First iteration

```text
each.key

subnet-public-1
```

```text
each.value

{
    cidr = "10.0.1.0/24"
    az   = "ap-south-1a"
}
```

Second iteration

```text
each.key

subnet-public-2
```

```text
each.value

{
    cidr = "10.0.2.0/24"
    az   = "ap-south-1b"
}
```

---

# What happened to `name`?

Earlier

```hcl
{
    name = "subnet-public-1"
    cidr = ...
}
```

Now

```hcl
subnet-public-1 = {
    cidr = ...
}
```

The key **is** the name.

Instead of

```hcl
each.value.name
```

you use

```hcl
each.key
```

---

# Visual comparison

## List Input

```text
[
   Object1,
   Object2
]
```

Need conversion

```text
↓

{
  subnet-public-1 = Object1
  subnet-public-2 = Object2
}
```

↓

`for_each`

---

## Map Input

Already

```text
{
  subnet-public-1 = Object1
  subnet-public-2 = Object2
}
```

↓

Directly

```hcl
for_each = var.subnets
```

No conversion.

---

# Resource addresses

Both approaches finally create exactly the same addresses.

```text
aws_subnet.public["subnet-public-1"]

aws_subnet.public["subnet-public-2"]
```

Terraform doesn't care whether the map came from your `tfvars` directly or was built using a `for` expression.

---

# Which approach is used in industry?

Both are used, depending on who owns the input data.

| Scenario                                             | Preferred Input                                                    |
| ---------------------------------------------------- | ------------------------------------------------------------------ |
| Human-written `terraform.tfvars`                     | ✅ `map(object(...))` because it's simpler for `for_each`           |
| Data coming from YAML, JSON, APIs, or another module | ✅ `list(object(...))` because external systems often produce lists |
| When order matters                                   | `list(object(...))`                                                |
| When stable resource identity matters                | `map(object(...))`                                                 |

### Practical examples

* **Platform teams** often define reusable modules with `list(object(...))` because consumers may generate the input dynamically from files or APIs, then convert to a map internally for `for_each`.
* **Application teams** writing a small `terraform.tfvars` by hand often prefer `map(object(...))` because they can pass it directly to `for_each` with less code.

So if you're designing a module for broad reuse, accepting a list and converting it internally is common. If you're writing infrastructure where the input is naturally keyed by name, using a map from the start is often the cleaner choice.

