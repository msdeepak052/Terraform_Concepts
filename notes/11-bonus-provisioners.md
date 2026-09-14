# Bonus — Provisioners

> **Important:** Provisioners are not a dedicated Terraform Associate exam domain, but they are referenced in the exam's core workflow/configuration material. The key thing HashiCorp wants you to understand is that **provisioners are a last resort**, not the preferred way to configure infrastructure. 

---

# 1. What Is a Provisioner?

A **provisioner** allows Terraform to execute a command or script:

* On the machine running Terraform, or
* On the newly created remote resource

Provisioners can run during:

* Resource creation
* Resource destruction

Terraform is primarily **declarative**:

```text
You declare WHAT you want
        ↓
Terraform/provider figures out HOW
```

A provisioner introduces an imperative step:

```text
Create resource
      ↓
Run this specific command/script
      ↓
Hope it succeeds
```

For example:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  provisioner "local-exec" {
    command = "echo Server created"
  }
}
```

The EC2 instance is created, and then Terraform executes the command.

---

# 2. Why Does HashiCorp Say "Provisioners Are a Last Resort"?

This is **very important for the exam**.

Terraform works best when infrastructure is represented declaratively.

HashiCorp recommends preferring:

### 1. Provider-native functionality

For example, AWS EC2 supports:

```hcl
user_data = <<-EOF
#!/bin/bash
yum install -y nginx
EOF
```

instead of using `remote-exec` to SSH into the server and install nginx.

---

### 2. Image baking

Use something like **Packer** to create an AMI that already contains the required software.

```text
Packer
   ↓
AMI with nginx installed
   ↓
Terraform
   ↓
EC2 launches ready
```

---

### 3. Configuration management

For more complex software configuration, use tools designed for that purpose, such as:

* Ansible
* Chef
* Puppet

These tools are designed specifically for configuring running machines.

---

### 4. Provisioners

Only use a provisioner when the above approaches cannot reasonably solve the requirement.

So remember:

```text
Provider-native feature
        ↓
Image baking
        ↓
Configuration management
        ↓
Provisioner
```

**Provisioner = last resort.**

The reason is that provisioners are imperative and can introduce ordering, connectivity, and reliability problems. 

---

# 3. Types of Provisioners

There are three important provisioners in the source:

| Provisioner   | Runs where?                    | Typical use                         |
| ------------- | ------------------------------ | ----------------------------------- |
| `local-exec`  | Machine running Terraform      | Local script, webhook, notification |
| `remote-exec` | Remote resource                | Execute commands on an EC2/VM       |
| `file`        | Copies file to remote resource | Upload config/script                |

The key distinction:

```text
local-exec
     ↓
YOUR machine / CI runner

remote-exec
     ↓
REMOTE server

file
     ↓
COPY file → remote server
```



---

# 4. Provisioner Syntax

Provisioners are defined **inside a resource block**.

Example:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  key_name      = var.key_name

  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> inventory.txt"
  }
}
```

Notice:

```hcl
provisioner "local-exec"
```

The provisioner is attached to:

```text
aws_instance.web
```

---

# 5. What Is `self`?

Inside a provisioner, `self` refers to the **resource that the provisioner belongs to**.

Example:

```hcl
resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo ${self.public_ip}"
  }
}
```

Here:

```text
self
 ↓
aws_instance.web
```

Therefore:

```hcl
self.id
self.public_ip
self.private_ip
```

refer to attributes of that EC2 instance.

### Exam point

If you need to reference the current resource's own attributes from its provisioner, use:

```hcl
self.attribute
```



---

# 6. `local-exec`

`local-exec` runs a command on the **machine executing Terraform**.

That could be:

* Your laptop
* A CI/CD runner
* Another machine executing Terraform

Example:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  provisioner "local-exec" {
    command = "echo Instance ${self.id} created with IP ${self.public_ip} >> created_instances.log"
  }
}
```

The command does **not** execute inside EC2.

It executes locally.

```text
Terraform runner
     │
     └── local-exec
            ↓
       created_instances.log
```

---

# 7. Practical `local-exec` Example

Suppose an EC2 instance is created and you want to notify another system.

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  provisioner "local-exec" {
    command = "curl -X POST https://example.com/webhook -d 'Instance created'"
  }
}
```

The `curl` command runs on the machine executing Terraform.

It doesn't run inside the EC2 instance.

### Typical uses

`local-exec` can be used for things such as:

* Updating a local inventory
* Calling an external webhook
* Running a local script
* Sending a notification



---

# 8. `remote-exec`

`remote-exec` runs commands **on the remote resource**.

For example, after creating an EC2 instance, you could SSH into it and install nginx.

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  key_name      = var.key_name

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx"
    ]
  }
}
```

The flow is:

```text
Terraform
    │
    ▼
Create EC2
    │
    ▼
Get public IP
    │
    ▼
SSH connection
    │
    ▼
remote-exec
    │
    ├── yum update
    ├── install nginx
    └── start nginx
```

---

# 9. `connection` Block

`remote-exec` needs to know **how to connect to the remote machine**.

That's why we use:

```hcl
connection {
  type        = "ssh"
  user        = "ec2-user"
  private_key = file("~/.ssh/id_rsa")
  host        = self.public_ip
}
```

Important attributes:

```text
type
 ↓
SSH

user
 ↓
Remote login user

private_key
 ↓
SSH private key

host
 ↓
Remote server address
```

Without a valid connection, `remote-exec` cannot reach the machine.

---

# 10. Why `remote-exec` Can Be Fragile

Suppose Terraform runs from a CI server.

The EC2 security group only allows SSH from:

```text
10.0.0.0/24
```

But the CI runner has a different public IP.

Then:

```text
Terraform CI runner
       │
       │ SSH
       X
       │
    EC2 instance
```

The connection fails.

Terraform may wait and eventually report an SSH timeout.

The Terraform configuration itself might be perfectly valid.

The problem is **network connectivity**.

This is one reason HashiCorp recommends avoiding provisioners when a better approach exists. 

---

# 11. Better Alternative — `user_data`

Instead of:

```text
Terraform
   ↓
SSH
   ↓
EC2
   ↓
Install nginx
```

you can use EC2 `user_data`.

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
  EOF
}
```

Now:

```text
Terraform
   ↓
Create EC2
   ↓
EC2 first boot
   ↓
cloud-init/user-data
   ↓
Install nginx
```

No SSH connection from Terraform is required.

### Why is this better?

Because the bootstrapping logic is part of the instance creation process rather than requiring Terraform to establish a live SSH connection at exactly the moment `apply` runs.



---

# 12. `remote-exec` vs `user_data`

| `remote-exec`                     | `user_data`                                     |
| --------------------------------- | ----------------------------------------------- |
| Terraform connects to server      | Server runs script during boot                  |
| Requires SSH/WinRM                | Doesn't require Terraform SSH                   |
| Sensitive to network connectivity | Less dependent on Terraform runner connectivity |
| Provisioner                       | Provider-native EC2 mechanism                   |
| Last-resort approach              | Generally preferred for EC2 bootstrap           |

### Exam mental model

If the question says:

> "Install software when an EC2 instance first boots."

Think:

**`user_data`**, not `remote-exec`.

If the question specifically asks:

> "Execute commands on an already-created remote machine through Terraform."

Think:

**`remote-exec`**.

---

# 13. `file` Provisioner

The `file` provisioner copies a file from the machine running Terraform to the remote resource.

Conceptually:

```text
Terraform machine
      │
      │ file provisioner
      ▼
Remote EC2
```

For example, you might copy:

```text
nginx.conf
```

to:

```text
/etc/nginx/nginx.conf
```

and then use `remote-exec` to restart nginx.

A typical combination is:

```text
file
 ↓
Copy configuration
 ↓
remote-exec
 ↓
Run command using configuration
```

Again, this should generally be considered only when provider-native or configuration-management approaches aren't suitable. 

---

# 14. Creation-Time Provisioners

By default, a provisioner runs during **resource creation**.

Example:

```hcl
resource "aws_instance" "web" {

  provisioner "local-exec" {
    command = "echo Created ${self.id}"
  }
}
```

The sequence is approximately:

```text
Create resource
      ↓
Provisioner executes
```

No `when` argument means creation-time behavior.

---

# 15. Destroy-Time Provisioners

You can also execute a provisioner when a resource is being destroyed.

Use:

```hcl
when = destroy
```

Example:

```hcl
resource "aws_instance" "web" {

  provisioner "local-exec" {
    when    = destroy
    command = "echo Destroying ${self.id}"
  }
}
```

Conceptually:

```text
Resource exists
      ↓
Terraform decides to destroy
      ↓
Destroy-time provisioner
      ↓
Resource destroyed
```

A useful example is deregistering an instance from a monitoring or load-balancing system before it disappears.



---

# 16. Important Destroy-Time Restriction

This is a good exam/troubleshooting detail.

A destroy-time provisioner has access to the **resource's own attributes** through `self`.

For example:

```hcl
self.id
self.tags
```

But it cannot freely reference another resource's live attributes.

Why?

Because Terraform's destroy operation can be removing multiple resources, and the other resource may already have been destroyed or changed by the time the provisioner runs.

So this kind of dependency is problematic:

```text
Resource A
   │
   └── destroy provisioner
          │
          └── needs live Resource B
```

Instead, if the destroy-time action needs some information from another resource, capture that information in the resource's own attributes/tags while it exists.

For example:

```hcl
self.tags["monitoring_id"]
```

can remain available to the destroy-time provisioner.



---

# 17. Example — Destroy-Time Deregistration

Suppose an EC2 instance is registered with a load balancer.

Before destroying it, you want to deregister it.

You could have information stored in the instance's tags:

```hcl
resource "aws_instance" "web" {

  tags = {
    tg_arn = var.target_group_arn
  }

  provisioner "local-exec" {
    when = destroy

    command = "aws elbv2 deregister-targets --target-group-arn ${self.tags["tg_arn"]} --targets Id=${self.id}"
  }
}
```

The important concept is:

```text
self.id
self.tags["tg_arn"]
```

Both belong to the resource itself.

---

# 18. Provisioner Failure Behavior

This is **very important**.

Provisioners have an:

```hcl
on_failure
```

argument.

Example:

```hcl
provisioner "remote-exec" {
  inline = [
    "sudo systemctl start nginx"
  ]

  on_failure = continue
}
```

There are two important values:

| Setting    | Behavior                                       |
| ---------- | ---------------------------------------------- |
| `fail`     | Stop and treat provisioner failure as an error |
| `continue` | Log the error but continue                     |

The default is:

```text
fail
```

---

# 19. `on_failure = fail`

This is the default.

```hcl
provisioner "remote-exec" {
  inline = ["sudo systemctl start nginx"]

  on_failure = fail
}
```

If the command fails:

```text
Provisioner fails
      ↓
Terraform reports error
      ↓
Resource is tainted
      ↓
Apply stops
```

The tainted resource can then be recreated on a subsequent apply.



---

# 20. `on_failure = continue`

With:

```hcl
on_failure = continue
```

Terraform logs the failure but continues.

```text
Provisioner fails
      ↓
Error logged
      ↓
Terraform continues
      ↓
Resource is NOT tainted
```

This should be used carefully.

For example, it might make sense for an optional notification:

```text
Create server
    ↓
Send Slack notification
    ↓
Slack unavailable
    ↓
Continue anyway
```

But it is dangerous for something essential:

```text
Create server
    ↓
Install application
    ↓
Installation fails
    ↓
on_failure = continue
    ↓
Terraform continues
```

Now Terraform can consider the resource successfully created even though the application setup failed.

So:

> **Use `continue` only when the provisioner's action is genuinely optional.**



---

# 21. Provisioners Are Not Idempotent

This is another key concept.

Terraform knows about resources and their declarative arguments.

It does **not** understand what your arbitrary shell command actually does.

For example:

```hcl
provisioner "remote-exec" {
  inline = [
    "echo hello >> /tmp/test.txt"
  ]
}
```

Terraform doesn't understand:

```text
"append hello to this file"
```

as a declarative desired state.

It simply executes the command.

Therefore:

> **Terraform does not provide idempotency guarantees for arbitrary provisioner commands.**

This is another reason provider-native resources and configuration-management tools are preferred. 

---

# 22. Failed Creation-Time Provisioner → Tainted Resource

Suppose:

```text
Create EC2
     ↓
remote-exec
     ↓
FAIL
```

With the default:

```hcl
on_failure = fail
```

the resource becomes **tainted**.

Conceptually:

```text
EC2 created
   ↓
Provisioner failed
   ↓
Resource tainted
   ↓
Next apply
   ↓
Destroy/recreate resource
   ↓
Provisioner runs again
```

This is why a failed provisioner can cause an otherwise successfully created resource to be recreated.



---

# 23. Provisioners Are Not Normal Declarative Resource Arguments

Consider:

```hcl
resource "aws_instance" "web" {
  instance_type = "t3.micro"
}
```

Terraform understands:

```text
instance_type = "t3.micro"
```

as part of the desired infrastructure configuration.

But:

```hcl
provisioner "local-exec" {
  command = "echo hello"
}
```

is essentially an imperative action attached to the resource lifecycle.

Terraform doesn't model the actual effect of:

```text
echo hello
```

as infrastructure state.

This is another reason provisioners are considered an escape hatch rather than a first-class infrastructure modeling mechanism.

---

# 24. `local-exec` vs `remote-exec` — Memorize This

This is probably the easiest provisioner question you'll see.

```text
local-exec
     ↓
Runs LOCALLY
     ↓
Machine running Terraform
```

```text
remote-exec
     ↓
Runs REMOTELY
     ↓
Created/managed resource
```

### Example

If Terraform is running on:

```text
CI Runner
```

then:

```hcl
local-exec
```

runs on:

```text
CI Runner
```

while:

```hcl
remote-exec
```

runs on:

```text
EC2
```

---

# 25. Provisioner Decision Tree

When you see a question asking how to configure a resource, think:

```text
Can provider-native functionality do it?
          │
         Yes
          ↓
       Use it
          │
         No
          ↓
Can you bake it into an image?
          │
         Yes
          ↓
     Use Packer
          │
         No
          ↓
Is this ongoing machine configuration?
          │
         Yes
          ↓
Ansible/Chef/Puppet/etc.
          │
         No
          ↓
Use provisioner
```

The main exam message is:

> **Don't reach for provisioners first.**

---

# ⭐ Provisioner Exam Cheat Sheet

| Concept                     | Remember                                                |
| --------------------------- | ------------------------------------------------------- |
| Provisioner                 | Imperative action attached to resource lifecycle        |
| Recommended?                | **Last resort**                                         |
| `local-exec`                | Runs on Terraform machine                               |
| `remote-exec`               | Runs on remote resource                                 |
| `file`                      | Copies files to remote resource                         |
| `self`                      | Current resource's attributes                           |
| `connection`                | Required to connect for `remote-exec`                   |
| `when` omitted              | Creation-time                                           |
| `when = destroy`            | Destroy-time                                            |
| `on_failure = fail`         | Default; failure stops apply/taints resource            |
| `on_failure = continue`     | Logs error and continues                                |
| Idempotency                 | Terraform doesn't guarantee it for provisioner commands |
| Better EC2 bootstrap        | `user_data`                                             |
| Better prebuilt software    | Packer/image baking                                     |
| Ongoing configuration       | Configuration management                                |
| Failed creation provisioner | Resource becomes tainted                                |
| Destroy provisioner         | Limited to own resource attributes via `self`           |

---

# 🧠 Final Mental Model

Remember these six things:

### 1. `local-exec`

**Local machine**

```text
Terraform → YOUR machine
```

### 2. `remote-exec`

**Remote machine**

```text
Terraform → SSH/WinRM → EC2
```

### 3. `file`

**Copy a file**

```text
Terraform machine → remote resource
```

### 4. `self`

**Current resource**

```text
self.id
self.public_ip
self.tags
```

### 5. `when`

```text
No when
    ↓
Create-time

when = destroy
    ↓
Destroy-time
```

### 6. `on_failure`

```text
fail
 ↓
Stop + taint

continue
 ↓
Log + continue
```

## 🔥 The most important exam sentence

> **Provisioners are a last resort because they introduce imperative, order-dependent operations and lack Terraform's normal declarative/idempotent guarantees. Prefer provider-native features, image baking, or configuration-management tools whenever possible.** 
