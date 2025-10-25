# 🌱 **1. What Are Variables in Terraform?**

In Terraform, **variables** are used to **parameterize** your infrastructure configuration — so you don’t hardcode values like region names, instance types, IPs, etc.

They make your code:
✅ Reusable
✅ Flexible
✅ Environment-agnostic (works for dev, test, prod)

---

# ⚙️ **2. Syntax — Declaring Variables**

You define variables using the `variable` block in `.tf` files.

### 🧩 Example:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
```

### Explanation:

* **variable "instance_type"** → Name of the variable
* **description** → Human-readable note (optional)
* **type** → Data type (e.g., string, number, bool, list, map, object, etc.)
* **default** → Default value (optional)
* If no default is provided, Terraform will **prompt you** for a value at runtime.

---

# 🧠 **3. Why Use Variables?**

Let’s say you want to create multiple EC2 instances in different environments (dev, test, prod).

Instead of hardcoding values:

```hcl
instance_type = "t2.micro"
```

You can use:

```hcl
instance_type = var.instance_type
```

This lets you reuse the same configuration across environments just by **changing variable values**.

---

# 🧩 **4. How to Use Variables (Referencing)**

Once defined, you reference variables using:

```hcl
var.<variable_name>
```

### Example:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

---

# 💡 **5. Ways to Assign Variable Values**

Terraform allows **5 main ways** to set variable values, in **order of precedence** (lowest to highest):

---

## **1️⃣ Default Value (inside variable block)**

If no other value is given, Terraform uses the `default`.

```hcl
variable "region" {
  default = "ap-south-1"
}
```

---

## **2️⃣ `terraform.tfvars` file**

You can create a file called `terraform.tfvars` or `<anything>.auto.tfvars`:

```hcl
region         = "us-east-1"
instance_type  = "t2.medium"
```

Terraform automatically loads it during `terraform plan` or `apply`.

---

## **3️⃣ Command Line Flag (`-var`)**

You can pass variables directly when running commands:

```bash
terraform apply -var="instance_type=t2.large" -var="region=us-east-1"
```

---

## **4️⃣ Environment Variables**

Prefix with `TF_VAR_` followed by variable name.

```bash
export TF_VAR_instance_type="t2.micro"
terraform apply
```

Terraform automatically picks this up.

---

## **5️⃣ Variable Files (`-var-file` option)**

You can have different files for environments:

```bash
terraform apply -var-file="dev.tfvars"
terraform apply -var-file="prod.tfvars"
```

**Example `dev.tfvars`:**

```hcl
region        = "ap-south-1"
instance_type = "t2.micro"
```

**Example `prod.tfvars`:**

```hcl
region        = "us-east-1"
instance_type = "t3.large"
```

---

# 🧱 **6. Types of Variables (by data type)**

Terraform supports various data types — let’s quickly recap:

| Type   | Description              | Example                         |
| ------ | ------------------------ | ------------------------------- |
| string | Text value               | `"t2.micro"`                    |
| number | Numeric value            | `3`                             |
| bool   | True/False               | `true`                          |
| list   | Ordered list             | `["a", "b"]`                    |
| map    | Key-value pairs          | `{ env = "dev" }`               |
| object | Structured record        | `{ name = "deepak", age = 30 }` |
| tuple  | Fixed order, mixed types | `["deepak", 30, true]`          |

---

# 🔁 **7. Variable Validation (Optional but Powerful)**

You can enforce rules using **validation blocks**.

### Example:

```hcl
variable "instance_type" {
  type = string

  validation {
    condition     = can(regex("^t2\\.", var.instance_type))
    error_message = "Instance type must start with 't2.'"
  }
}
```

If someone provides `m5.large`, Terraform will throw an error.

---

# 🧩 **8. Sensitive Variables (for Secrets)**

Mark variables as sensitive so they don’t show in CLI output or logs.

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

Use `terraform output -json` or `terraform console` to view them securely if needed.

---

# 🌍 **9. Real-Life Example: Using Variables for Multi-Environment EC2 Setup**

Let’s bring everything together 👇

### **Files:**

#### 📄 `variables.tf`

```hcl
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_tags" {
  description = "Tags for EC2 instance"
  type        = map(string)
}

variable "key_name" {
  description = "Key pair for SSH"
  type        = string
}
```

#### 📄 `terraform.tfvars` (for dev)

```hcl
instance_type = "t2.micro"
key_name      = "dev-key"
instance_tags = {
  Name        = "dev-server"
  Environment = "development"
}
```

#### 📄 `main.tf`

```hcl
provider "aws" {
  region = var.region
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type
  key_name      = var.key_name
  tags          = var.instance_tags
}
```

### **Usage:**

```bash
terraform init
terraform plan
terraform apply
```

✅ Terraform will:

* Read the variables from `terraform.tfvars`
* Create an EC2 instance with those values
* Tag it dynamically using variable data

---

# 💼 **10. Real-Life Enterprise Example**

Let’s take a real DevOps use case 👇

### Scenario:

You’re setting up **different environments** (Dev, QA, Prod) using the same Terraform codebase.

### Goal:

Use **variables** to customize:

* VPC CIDR
* EC2 instance size
* Tags
* Number of instances

#### **dev.tfvars**

```hcl
vpc_cidr       = "10.0.0.0/24"
instance_type  = "t2.micro"
instance_count = 1
tags = {
  Environment = "Dev"
}
```

#### **prod.tfvars**

```hcl
vpc_cidr       = "10.1.0.0/16"
instance_type  = "t3.large"
instance_count = 3
tags = {
  Environment = "Production"
}
```

#### **main.tf**

```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = var.tags
}

resource "aws_instance" "server" {
  count         = var.instance_count
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type
  tags          = merge(var.tags, { Name = "server-${count.index}" })
}
```

### Run:

```bash
terraform apply -var-file="dev.tfvars"
terraform apply -var-file="prod.tfvars"
```

✅ **Result:**
Same Terraform code provisions:

* Small single instance in Dev
* Multiple large servers in Prod

All controlled by variables.

---

# 🏁 **Conclusion**

| Concept       | Purpose                                  | Example                                 |
| ------------- | ---------------------------------------- | --------------------------------------- |
| Variable      | Make config reusable                     | `variable "region" {}`                  |
| Usage         | Reference inside resources               | `region = var.region`                   |
| Sources       | default, tfvars, CLI, env vars, var-file | `terraform apply -var-file=prod.tfvars` |
| Best Practice | Use validation + sensitive for security  | `sensitive = true`                      |

---

